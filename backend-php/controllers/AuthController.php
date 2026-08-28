<?php

class AuthController
{
    public static function register(): void
    {
        $body = Request::jsonBody();
        $name = $body['name'] ?? '';
        $email = $body['email'] ?? '';
        $password = $body['password'] ?? '';
        $role = $body['role'] ?? '';
        $academy = $body['academy'] ?? '';
        $resellerKind = strtolower(trim((string) ($body['reseller_kind'] ?? '')));

        if (!$name || !$email || !$password) {
            Response::error('Name, email and password are required', 400);
        }

        $userRole = $role === 'reseller' ? 'reseller' : 'customer';
        $academyName = trim((string) $academy);

        // Meeting model (app sends reseller_kind):
        // independent → VNA-B, 53% (rest Digititan)
        // affiliated  → VNA-B, 53% + centre name (centre 26% / Digititan 21%)
        // centre      → VNA-C, 26% (rest Digititan)
        // Backward compatible: blank academy = independent, filled = affiliated
        if ($userRole === 'reseller') {
            if ($resellerKind === '' || !in_array($resellerKind, ['independent', 'affiliated', 'centre'], true)) {
                $resellerKind = $academyName === '' ? 'independent' : 'affiliated';
            }
            if ($resellerKind === 'affiliated' && $academyName === '') {
                Response::error('Please enter the centre / academy you are affiliated with', 400);
            }
            if ($resellerKind === 'centre' && $academyName === '') {
                Response::error('Please enter your centre / academy organisation name', 400);
            }
        }

        if (User::emailExists($email)) {
            Response::error('Email already registered', 409);
        }

        $hash = password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
        $approvalStatus = $userRole === 'customer' ? 'approved' : 'pending';

        // No email-confirm link for v1 — welcome mail only; account usable immediately.
        $result = Database::queryRun(
            'INSERT INTO registrations (name, role, verification_token, is_verified, is_approved) VALUES (?, ?, NULL, 1, ?)',
            [$name, $userRole, $approvalStatus]
        );
        $userId = $result['lastInsertRowid'];

        Database::queryRun(
            'INSERT INTO logins (registration_id, email, password) VALUES (?, ?, ?)',
            [$userId, strtolower(trim($email)), $hash]
        );

        if ($userRole === 'reseller') {
            if ($resellerKind === 'independent') {
                $academyName = 'Independent (Digititan programme support)';
            }

            $suffix = strtoupper(substr(str_replace('-', '', Request::uuid()), 0, 8));
            if ($resellerKind === 'centre') {
                $referralCode = 'VNA-C-' . $suffix;
                $commissionRate = 26.00;
                $kindLabel = 'Centre (VNA-C)';
            } else {
                $referralCode = 'VNA-B-' . $suffix;
                $commissionRate = 53.00;
                $kindLabel = $resellerKind === 'affiliated'
                    ? 'Beneficiary affiliated (VNA-B)'
                    : 'Independent beneficiary (VNA-B)';
            }

            Database::queryRun(
                'INSERT INTO reseller_profiles (user_id, referral_code, academy, commission_rate) VALUES (?, ?, ?, ?)',
                [$userId, $referralCode, $academyName, $commissionRate]
            );
            try {
                Mailer::send([
                    'to' => Site::email(),
                    'replyTo' => $email,
                    'subject' => "New reseller registration: $name",
                    'html' => "<p><strong>Name:</strong> " . htmlspecialchars($name) . "</p>
                        <p><strong>Email:</strong> " . htmlspecialchars($email) . "</p>
                        <p><strong>Kind:</strong> " . htmlspecialchars($kindLabel) . "</p>
                        <p><strong>Academy:</strong> " . htmlspecialchars($academyName) . "</p>
                        <p><strong>Referral code:</strong> $referralCode</p>
                        <p><strong>Commission rate:</strong> {$commissionRate}%</p>",
                ]);
            } catch (Throwable $e) {
                error_log('[Auth] reseller notify mail skipped: ' . $e->getMessage());
            }
        }

        try {
            $site = rtrim((string) Client::getClientUrl(), '/');
            $safeName = htmlspecialchars($name);
            $safeEmail = htmlspecialchars($email);
            $roleLine = $userRole === 'reseller'
                ? '<p>Your <strong>reseller</strong> application is with us. Ops must approve it before you can sign in as a reseller.</p>'
                : '<p>You registered as a <strong>customer</strong>. You can sign in on the app and the website with this email right away.</p>';

            Mailer::send([
                'to' => $email,
                'subject' => 'Welcome to Village NetAcad',
                'html' => "<h2>Welcome, {$safeName}!</h2>
                    <p>Your Village NetAcad account is ready.</p>
                    <p><strong>Email:</strong> {$safeEmail}</p>
                    {$roleLine}
                    <h3>What you can do</h3>
                    <ul>
                      <li><strong>Shop</strong> — browse kit and merch in the app, then complete checkout on the website (PayFast).</li>
                      <li><strong>Training</strong> — free Cisco NetAcad skills courses and the paid CCNA pathway via the website.</li>
                      <li><strong>Academies</strong> — explore academy / NPO pathways on the site and in the app.</li>
                      <li><strong>Reseller</strong> — apply from the app or site; approved sellers get a VNA-B or VNA-C code and wallet.</li>
                    </ul>
                    <p>Website: <a href=\"{$site}\">{$site}</a></p>
                    <p>Use the same email and password on the <strong>Village NetAcad</strong> mobile app and on the website.</p>
                    <p>Questions? Reply to this email or write to <a href=\"mailto:info@villagenetacad.co.za\">info@villagenetacad.co.za</a>.</p>
                    <p>— Village NetAcad · Powered by Digititan</p>",
            ]);
        } catch (Throwable $e) {
            error_log('[Auth] welcome mail skipped: ' . $e->getMessage());
        }

        if ($userRole === 'reseller' && $approvalStatus === 'pending') {
            Response::json([
                'pending' => true,
                'message' => 'Reseller account created. An admin must approve it before you can sign in.',
                'user' => [
                    'id' => $userId,
                    'name' => $name,
                    'email' => $email,
                    'role' => $userRole,
                    'is_approved' => $approvalStatus,
                ],
            ], 201);
        }

        Response::json([
            'token' => Jwt::sign($userId),
            'user' => [
                'id' => $userId,
                'name' => $name,
                'email' => $email,
                'role' => $userRole,
                'is_approved' => $approvalStatus,
            ],
        ], 201);
    }

    public static function login(): void
    {
        $body = Request::jsonBody();
        $email = strtolower(trim((string) ($body['email'] ?? '')));
        $password = $body['password'] ?? '';

        if (!$email || !$password) {
            Response::error('Email and password are required', 400);
        }

        $user = User::findByEmailForAuth($email);
        if (!$user || !password_verify($password, $user['password'])) {
            Response::error('Invalid credentials', 401);
        }

        if ($user['is_approved'] === 'declined') {
            Response::error('Your account has been declined by an administrator', 403);
        }
        if ($user['is_approved'] === 'pending' && $user['role'] !== 'admin') {
            Response::error('Your account is pending admin approval', 403);
        }

        Database::queryRun('UPDATE logins SET last_login_at = NOW() WHERE registration_id = ?', [$user['id']]);

        Response::json([
            'token' => Jwt::sign((int) $user['id']),
            'user' => [
                'id' => (int) $user['id'],
                'name' => $user['name'],
                'email' => $user['email'],
                'role' => $user['role'],
                'avatar' => $user['avatar'],
                'is_approved' => $user['is_approved'],
            ],
        ]);
    }

    public static function verifyEmail(): void
    {
        $token = Request::query('token');
        $user = Database::queryGet('SELECT id FROM registrations WHERE verification_token = ?', [$token]);
        if (!$user) {
            Response::error('Invalid verification token', 400);
        }
        Database::queryRun(
            'UPDATE registrations SET is_verified = 1, verification_token = NULL WHERE id = ?',
            [$user['id']]
        );
        Response::json(['message' => 'Email verified successfully']);
    }

    public static function forgotPassword(): void
    {
        $body = Request::jsonBody();
        $email = $body['email'] ?? '';
        $user = User::findByEmailForAuth($email);

        if ($user) {
            $resetToken = Request::uuid();
            $expires = gmdate('c', time() + 3600);
            Database::queryRun(
                'UPDATE logins SET reset_token = ?, reset_token_expires = ? WHERE registration_id = ?',
                [$resetToken, $expires, $user['id']]
            );
            $resetUrl = Client::getClientUrl() . '/reset-password?token=' . urlencode($resetToken);
            Mailer::send([
                'to' => $email,
                'subject' => 'Password Reset - Village NetAcad',
                'html' => '<h2>Hi ' . htmlspecialchars($user['name']) . '</h2>
                    <p>Click <a href="' . $resetUrl . '">here</a> to reset your password. Expires in 1 hour.</p>',
            ]);
        }

        Response::json(['message' => 'If that email exists, a reset link was sent']);
    }

    public static function resetPassword(): void
    {
        $body = Request::jsonBody();
        $token = $body['token'] ?? '';
        $password = $body['password'] ?? '';

        $login = Database::queryGet(
            "SELECT registration_id FROM logins WHERE reset_token = ? AND reset_token_expires > NOW()",
            [$token]
        );
        if (!$login) {
            Response::error('Invalid or expired reset token', 400);
        }

        $hash = password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
        Database::queryRun(
            'UPDATE logins SET password = ?, reset_token = NULL, reset_token_expires = NULL WHERE registration_id = ?',
            [$hash, $login['registration_id']]
        );
        Response::json(['message' => 'Password reset successfully']);
    }

    public static function me(): void
    {
        Auth::authenticate();
        Response::json(['user' => Auth::$user]);
    }

    public static function logout(): void
    {
        Response::json(['message' => 'Logged out successfully']);
    }
}
