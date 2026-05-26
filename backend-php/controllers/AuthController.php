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

        if (!$name || !$email || !$password) {
            Response::error('Name, email and password are required', 400);
        }

        $userRole = $role === 'reseller' ? 'reseller' : 'customer';
        if ($userRole === 'reseller') {
            $academyName = trim((string) $academy);
            if ($academyName === '') {
                Response::error('Please enter the name of your academy', 400);
            }
        }

        $existing = Database::queryGet('SELECT id FROM users WHERE email = ?', [$email]);
        if ($existing) {
            Response::error('Email already registered', 409);
        }

        $hash = password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
        $verificationToken = Request::uuid();
        $approvalStatus = $userRole === 'customer' ? 'approved' : 'pending';

        $result = Database::queryRun(
            'INSERT INTO users (name, email, password, role, verification_token, is_approved) VALUES (?, ?, ?, ?, ?, ?)',
            [$name, $email, $hash, $userRole, $verificationToken, $approvalStatus]
        );
        $userId = $result['lastInsertRowid'];

        if ($userRole === 'reseller') {
            $academyName = trim((string) $academy);
            $referralCode = 'VNA-' . strtoupper(substr(str_replace('-', '', Request::uuid()), 0, 8));
            Database::queryRun(
                'INSERT INTO reseller_profiles (user_id, referral_code, academy) VALUES (?, ?, ?)',
                [$userId, $referralCode, $academyName]
            );
            Mailer::send([
                'to' => Site::email(),
                'replyTo' => $email,
                'subject' => "New reseller registration: $name",
                'html' => "<p><strong>Name:</strong> " . htmlspecialchars($name) . "</p>
                    <p><strong>Email:</strong> " . htmlspecialchars($email) . "</p>
                    <p><strong>Academy:</strong> " . htmlspecialchars($academyName) . "</p>
                    <p><strong>Referral code:</strong> $referralCode</p>",
            ]);
        }

        $verifyUrl = Client::getClientUrl() . '/verify-email?token=' . urlencode($verificationToken);
        Mailer::send([
            'to' => $email,
            'subject' => 'Verify your Village NetAcad account',
            'html' => "<h2>Welcome " . htmlspecialchars($name) . "!</h2>
                <p>Click <a href=\"$verifyUrl\">here</a> to verify your email.</p>",
        ]);

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

        $user = Database::queryGet('SELECT * FROM users WHERE LOWER(email) = ?', [$email]);
        if (!$user || !password_verify($password, $user['password'])) {
            Response::error('Invalid credentials', 401);
        }

        if ($user['is_approved'] === 'declined') {
            Response::error('Your account has been declined by an administrator', 403);
        }
        if ($user['is_approved'] === 'pending' && $user['role'] !== 'admin') {
            Response::error('Your account is pending admin approval', 403);
        }

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
        $user = Database::queryGet('SELECT id FROM users WHERE verification_token = ?', [$token]);
        if (!$user) {
            Response::error('Invalid verification token', 400);
        }
        Database::queryRun(
            'UPDATE users SET is_verified = 1, verification_token = NULL WHERE id = ?',
            [$user['id']]
        );
        Response::json(['message' => 'Email verified successfully']);
    }

    public static function forgotPassword(): void
    {
        $body = Request::jsonBody();
        $email = $body['email'] ?? '';
        $user = Database::queryGet('SELECT id, name FROM users WHERE email = ?', [$email]);

        if ($user) {
            $resetToken = Request::uuid();
            $expires = gmdate('c', time() + 3600);
            Database::queryRun(
                'UPDATE users SET reset_token = ?, reset_token_expires = ? WHERE id = ?',
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

        $user = Database::queryGet(
            "SELECT id FROM users WHERE reset_token = ? AND reset_token_expires > datetime('now')",
            [$token]
        );
        if (!$user) {
            Response::error('Invalid or expired reset token', 400);
        }

        $hash = password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
        Database::queryRun(
            'UPDATE users SET password = ?, reset_token = NULL, reset_token_expires = NULL WHERE id = ?',
            [$hash, $user['id']]
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
