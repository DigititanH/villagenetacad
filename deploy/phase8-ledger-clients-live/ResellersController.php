<?php

class ResellersController
{
    private const MIN_WITHDRAWAL_ZAR = 100.0;

    private static function requireApprovedReseller(): void
    {
        $profile = Database::queryGet('SELECT status FROM reseller_profiles WHERE user_id = ?', [Auth::$user['id']]);
        if (!$profile) {
            Response::error('Reseller profile not found', 404);
        }
        if ($profile['status'] !== 'approved') {
            Response::error('Reseller account is pending admin approval', 403);
        }
    }

    /**
     * Public legitimacy check — no auth, no wallet/bank/email secrets.
     * GET /api/resellers/verify/{code}
     */
    public static function verify(array $params): void
    {
        $code = strtoupper(trim((string) ($params['code'] ?? '')));
        if ($code === '') {
            Response::error('Reseller code is required', 400);
        }

        $row = Database::queryGet(
            'SELECT rp.referral_code, rp.status, rp.academy, r.name
             FROM reseller_profiles rp
             JOIN registrations r ON rp.user_id = r.id
             WHERE UPPER(rp.referral_code) = ?',
            [$code]
        );
        if (!$row) {
            Response::error('Code not found or inactive', 404);
        }

        $approved = ($row['status'] ?? '') === 'approved';
        Response::json([
            'code' => $row['referral_code'],
            'name' => $row['name'],
            'academy' => $row['academy'],
            'status' => $row['status'],
            'approved' => $approved,
            'active' => $approved,
        ]);
    }

    public static function profile(): void
    {
        Auth::authorize('reseller');
        $row = Database::queryGet(
            'SELECT rp.*, r.name, l.email, r.is_approved FROM reseller_profiles rp
             JOIN registrations r ON rp.user_id = r.id
             JOIN logins l ON l.registration_id = r.id WHERE rp.user_id = ?',
            [Auth::$user['id']]
        );
        if (!$row) {
            Response::error('Reseller profile not found', 404);
        }

        if ($row['is_approved'] === 'approved' && $row['status'] === 'pending') {
            Database::queryRun("UPDATE reseller_profiles SET status = 'approved' WHERE user_id = ?", [Auth::$user['id']]);
            $row['status'] = 'approved';
        }
        if ($row['is_approved'] === 'declined' && $row['status'] === 'pending') {
            Database::queryRun("UPDATE reseller_profiles SET status = 'rejected' WHERE user_id = ?", [Auth::$user['id']]);
            $row['status'] = 'rejected';
        }

        $totals = self::shareTotalsForReseller((int) $row['id']);
        $row['amount_due_to_digititan'] = $totals['digititan'];
        $row['centre_share_total'] = $totals['centre'];
        $row['seller_share_total'] = $totals['seller'];

        Response::json($row);
    }

    /** Lifetime share totals from commissions ledger (party column when present). */
    private static function shareTotalsForReseller(int $resellerId): array
    {
        $seller = 0.0;
        $centre = 0.0;
        $digititan = 0.0;
        try {
            $rows = Database::queryAll(
                'SELECT amount, party FROM commissions WHERE reseller_id = ?',
                [$resellerId]
            );
            foreach ($rows as $r) {
                $party = (string) ($r['party'] ?? 'seller');
                $amt = (float) $r['amount'];
                if ($party === 'digititan') {
                    $digititan += $amt;
                } elseif ($party === 'centre') {
                    $centre += $amt;
                } else {
                    $seller += $amt;
                }
            }

            // Affiliated seller: centre 26% was credited to the centre profile — still
            // show how much of *this* seller's sales went to their linked centre.
            $profile = Database::queryGet(
                'SELECT referral_code, academy FROM reseller_profiles WHERE id = ?',
                [$resellerId]
            );
            $ref = strtoupper(trim((string) ($profile['referral_code'] ?? '')));
            $academy = trim((string) ($profile['academy'] ?? ''));
            if (strpos($ref, 'VNA-C-') !== 0 && $academy !== '') {
                $attr = Database::queryGet(
                    "SELECT COALESCE(SUM(c2.amount), 0) AS s
                     FROM commissions c1
                     JOIN commissions c2
                       ON c2.order_id = c1.order_id AND c2.party = 'centre'
                     WHERE c1.reseller_id = ? AND c1.party = 'seller'",
                    [$resellerId]
                );
                $centre = (float) ($attr['s'] ?? 0);
            }
        } catch (Throwable $e) {
            $sum = Database::queryGet(
                'SELECT COALESCE(SUM(amount),0) AS s FROM commissions WHERE reseller_id = ?',
                [$resellerId]
            );
            $seller = (float) ($sum['s'] ?? 0);
        }
        return [
            'seller' => round($seller, 2),
            'centre' => round($centre, 2),
            'digititan' => round($digititan, 2),
        ];
    }

    public static function commissions(): void
    {
        Auth::authorize('reseller');
        self::requireApprovedReseller();
        $profile = Database::queryGet('SELECT id FROM reseller_profiles WHERE user_id = ?', [Auth::$user['id']]);
        if (!$profile) {
            Response::error('Profile not found', 404);
        }
        Response::json(Database::queryAll(
            'SELECT c.*, o.total as order_total, o.created_at as order_date FROM commissions c
             JOIN orders o ON c.order_id = o.id WHERE c.reseller_id = ? ORDER BY c.created_at DESC',
            [$profile['id']]
        ));
    }

    public static function sales(): void
    {
        Auth::authorize('reseller');
        self::requireApprovedReseller();
        $profile = Database::queryGet('SELECT id FROM reseller_profiles WHERE user_id = ?', [Auth::$user['id']]);
        if (!$profile) {
            Response::error('Profile not found', 404);
        }
        try {
            Response::json(Database::queryAll(
                "SELECT o.id, o.total, o.status, o.created_at, r.name as customer_name,
                        c.amount as commission_amount, c.party, c.share_percent
                 FROM commissions c
                 JOIN orders o ON c.order_id = o.id
                 JOIN registrations r ON o.user_id = r.id
                 WHERE c.reseller_id = ?
                   AND (c.party IS NULL OR c.party IN ('seller','centre'))
                 ORDER BY o.created_at DESC",
                [$profile['id']]
            ));
        } catch (Throwable $e) {
            Response::json(Database::queryAll(
                'SELECT o.id, o.total, o.status, o.created_at, r.name as customer_name FROM commissions c
                 JOIN orders o ON c.order_id = o.id JOIN registrations r ON o.user_id = r.id
                 WHERE c.reseller_id = ? ORDER BY o.created_at DESC',
                [$profile['id']]
            ));
        }
    }

    /**
     * Month-end earnings statement from live commissions.
     * GET /api/resellers/statement?month=YYYY-MM (defaults to current UTC month)
     */
    public static function statement(): void
    {
        Auth::authorize('reseller');
        self::requireApprovedReseller();
        $profile = Database::queryGet(
            'SELECT id, referral_code, commission_rate, academy, wallet_balance, total_earned
             FROM reseller_profiles WHERE user_id = ?',
            [Auth::$user['id']]
        );
        if (!$profile) {
            Response::error('Profile not found', 404);
        }

        $month = trim((string) (Request::query('month') ?? ''));
        if ($month === '' || !preg_match('/^\d{4}-\d{2}$/', $month)) {
            $month = gmdate('Y-m');
        }
        $start = $month . '-01 00:00:00';
        $end = gmdate('Y-m-d H:i:s', strtotime($start . ' +1 month'));

        $lines = [];
        try {
            $lines = Database::queryAll(
                "SELECT c.id, c.amount, c.party, c.share_percent, c.created_at,
                        o.id AS order_id, o.total AS order_total, o.created_at AS order_date,
                        r.name AS customer_name
                 FROM commissions c
                 JOIN orders o ON o.id = c.order_id
                 JOIN registrations r ON r.id = o.user_id
                 WHERE c.reseller_id = ?
                   AND c.created_at >= ? AND c.created_at < ?
                 ORDER BY c.created_at DESC",
                [$profile['id'], $start, $end]
            );
        } catch (Throwable $e) {
            $lines = Database::queryAll(
                "SELECT c.id, c.amount, c.created_at,
                        o.id AS order_id, o.total AS order_total, o.created_at AS order_date,
                        r.name AS customer_name
                 FROM commissions c
                 JOIN orders o ON o.id = c.order_id
                 JOIN registrations r ON r.id = o.user_id
                 WHERE c.reseller_id = ?
                   AND c.created_at >= ? AND c.created_at < ?
                 ORDER BY c.created_at DESC",
                [$profile['id'], $start, $end]
            );
            foreach ($lines as &$line) {
                $line['party'] = 'seller';
                $line['share_percent'] = null;
            }
            unset($line);
        }

        $sellerEarned = 0.0;
        $centreEarned = 0.0;
        $digititanDue = 0.0;
        $orderTotal = 0.0;
        $seenOrders = [];
        foreach ($lines as $line) {
            $party = (string) ($line['party'] ?? 'seller');
            $amt = (float) $line['amount'];
            if ($party === 'digititan') {
                $digititanDue += $amt;
            } elseif ($party === 'centre') {
                $centreEarned += $amt;
            } else {
                $sellerEarned += $amt;
            }
            $oid = (string) ($line['order_id'] ?? '');
            if ($oid !== '' && !isset($seenOrders[$oid])) {
                $seenOrders[$oid] = true;
                $orderTotal += (float) ($line['order_total'] ?? 0);
            }
        }

        // Old DBs without party: estimate Digititan from order totals − wallet lines.
        if ($digititanDue <= 0 && $orderTotal > 0) {
            $walletLines = $sellerEarned + $centreEarned;
            $digititanDue = max(0, round($orderTotal - $walletLines, 2));
        }

        $ref = strtoupper(trim((string) $profile['referral_code']));
        $isCentre = strpos($ref, 'VNA-C-') === 0;
        $affiliated = !$isCentre && trim((string) ($profile['academy'] ?? '')) !== '';

        Response::json([
            'month' => $month,
            'referral_code' => $profile['referral_code'],
            'commission_rate' => (float) $profile['commission_rate'],
            'academy' => $profile['academy'],
            'is_centre' => $isCentre,
            'affiliated' => $affiliated,
            'wallet_balance' => (float) $profile['wallet_balance'],
            'total_earned' => (float) $profile['total_earned'],
            'period' => [
                'orders_total' => round($orderTotal, 2),
                'seller_earned' => round($sellerEarned, 2),
                'centre_earned' => round($centreEarned, 2),
                'digititan_due' => round($digititanDue, 2),
                'line_count' => count($lines),
            ],
            'lines' => $lines,
            'withdraw_rules' => [
                'min_zar' => self::MIN_WITHDRAWAL_ZAR,
                'last_calendar_day_only' => true,
            ],
        ]);
    }

    public static function clients(): void
    {
        Auth::authorize('reseller');
        self::requireApprovedReseller();
        $profile = Database::queryGet('SELECT id FROM reseller_profiles WHERE user_id = ?', [Auth::$user['id']]);
        if (!$profile) {
            Response::error('Profile not found', 404);
        }
        Response::json(Database::queryAll(
            'SELECT * FROM reseller_clients WHERE reseller_id = ? ORDER BY updated_at DESC',
            [$profile['id']]
        ));
    }

    public static function addClient(): void
    {
        Auth::authorize('reseller');
        self::requireApprovedReseller();
        $profile = Database::queryGet('SELECT id FROM reseller_profiles WHERE user_id = ?', [Auth::$user['id']]);
        if (!$profile) {
            Response::error('Profile not found', 404);
        }

        $body = Request::jsonBody();
        $name = trim((string) ($body['name'] ?? ''));
        $email = strtolower(trim((string) ($body['email'] ?? '')));
        $interest = trim((string) ($body['product_interest'] ?? $body['productInterest'] ?? ''));
        $status = self::normalizeClientStatus($body['status'] ?? 'pending');

        if ($name === '' || $email === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
            Response::error('Name and valid email are required', 400);
        }

        $result = Database::queryRun(
            'INSERT INTO reseller_clients (reseller_id, name, email, product_interest, status)
             VALUES (?, ?, ?, ?, ?)',
            [$profile['id'], $name, $email, $interest !== '' ? $interest : null, $status]
        );
        $row = Database::queryGet('SELECT * FROM reseller_clients WHERE id = ?', [$result['lastInsertRowid']]);
        Response::json($row, 201);
    }

    public static function updateClient(array $params): void
    {
        Auth::authorize('reseller');
        self::requireApprovedReseller();
        $profile = Database::queryGet('SELECT id FROM reseller_profiles WHERE user_id = ?', [Auth::$user['id']]);
        if (!$profile) {
            Response::error('Profile not found', 404);
        }

        $clientId = (int) ($params['id'] ?? 0);
        $row = Database::queryGet(
            'SELECT * FROM reseller_clients WHERE id = ? AND reseller_id = ?',
            [$clientId, $profile['id']]
        );
        if (!$row) {
            Response::error('Client not found', 404);
        }

        $body = Request::jsonBody();
        $status = self::normalizeClientStatus($body['status'] ?? $row['status']);
        Database::queryRun(
            'UPDATE reseller_clients SET status = ?, updated_at = NOW() WHERE id = ?',
            [$status, $clientId]
        );
        Response::json(Database::queryGet('SELECT * FROM reseller_clients WHERE id = ?', [$clientId]));
    }

    private static function normalizeClientStatus(mixed $raw): string
    {
        $s = strtolower(trim((string) $raw));
        $map = [
            'pending' => 'pending',
            'confirmed' => 'confirmed',
            'bought' => 'bought',
            'did_not_buy' => 'did_not_buy',
            'didnotbuy' => 'did_not_buy',
            'did-not-buy' => 'did_not_buy',
        ];
        if (!isset($map[$s])) {
            Response::error('Invalid client status', 400);
        }
        return $map[$s];
    }

    public static function withdraw(): void
    {
        Auth::authorize('reseller');
        self::requireApprovedReseller();
        $body = Request::jsonBody();
        $amount = (float) ($body['amount'] ?? 0);
        $bankDetails = $body['bank_details'] ?? [];

        if ($amount <= 0) {
            Response::error('Withdrawal amount must be greater than zero', 400);
        }
        if ($amount < self::MIN_WITHDRAWAL_ZAR) {
            Response::error('Minimum withdrawal is R100', 400);
        }

        $today = (int) gmdate('j');
        $lastDay = (int) gmdate('t');
        if ($today !== $lastDay) {
            Response::error(
                'Withdrawals are only allowed on the last calendar day of the month',
                400
            );
        }

        $profile = Database::queryGet('SELECT id, wallet_balance FROM reseller_profiles WHERE user_id = ?', [Auth::$user['id']]);
        if (!$profile) {
            Response::error('Profile not found', 404);
        }
        if ($amount > (float) $profile['wallet_balance']) {
            Response::error('Insufficient balance', 400);
        }

        Database::queryRun(
            'INSERT INTO withdrawals (reseller_id, amount, bank_details) VALUES (?, ?, ?)',
            [$profile['id'], $amount, json_encode($bankDetails)]
        );
        Database::queryRun(
            'UPDATE reseller_profiles SET wallet_balance = wallet_balance - ? WHERE id = ?',
            [$amount, $profile['id']]
        );

        Mailer::send([
            'to' => Site::email(),
            'replyTo' => Auth::$user['email'],
            'subject' => "Withdrawal request: R$amount from " . Auth::$user['name'],
            'html' => '<p><strong>Reseller:</strong> ' . htmlspecialchars(Auth::$user['name']) . ' (' . htmlspecialchars(Auth::$user['email']) . ')</p>
                <p><strong>Amount:</strong> R' . $amount . '</p>
                <p><strong>Bank details:</strong><br><pre>' . htmlspecialchars(json_encode($bankDetails, JSON_PRETTY_PRINT)) . '</pre></p>',
        ]);

        Response::json(['message' => 'Withdrawal request submitted'], 201);
    }

    public static function withdrawals(): void
    {
        Auth::authorize('reseller');
        self::requireApprovedReseller();
        $profile = Database::queryGet('SELECT id FROM reseller_profiles WHERE user_id = ?', [Auth::$user['id']]);
        if (!$profile) {
            Response::error('Profile not found', 404);
        }
        Response::json(Database::queryAll(
            'SELECT * FROM withdrawals WHERE reseller_id = ? ORDER BY created_at DESC',
            [$profile['id']]
        ));
    }

    public static function adminAll(): void
    {
        Auth::authorize('admin');
        Response::json(Database::queryAll(
            'SELECT rp.*, r.name, l.email FROM reseller_profiles rp
             JOIN registrations r ON rp.user_id = r.id
             JOIN logins l ON l.registration_id = r.id ORDER BY rp.created_at DESC'
        ));
    }

    public static function adminStatus(array $params): void
    {
        Auth::authorize('admin');
        $body = Request::jsonBody();
        $status = $body['status'] ?? '';
        if (!in_array($status, ['approved', 'rejected', 'suspended'], true)) {
            Response::error('Invalid status', 400);
        }

        Database::queryRun('UPDATE reseller_profiles SET status = ? WHERE id = ?', [$status, $params['id']]);
        $profile = Database::queryGet('SELECT user_id FROM reseller_profiles WHERE id = ?', [$params['id']]);
        if ($profile) {
            $userStatus = $status === 'approved' ? 'approved' : 'declined';
            Database::queryRun('UPDATE registrations SET is_approved = ? WHERE id = ?', [$userStatus, $profile['user_id']]);
        }
        Response::json(['message' => "Reseller $status"]);
    }

    public static function adminWithdrawals(): void
    {
        Auth::authorize('admin');
        Response::json(Database::queryAll(
            'SELECT w.*, rp.referral_code, r.name, l.email FROM withdrawals w
             JOIN reseller_profiles rp ON w.reseller_id = rp.id
             JOIN registrations r ON rp.user_id = r.id
             JOIN logins l ON l.registration_id = r.id ORDER BY w.created_at DESC'
        ));
    }

    public static function adminWithdrawalUpdate(array $params): void
    {
        Auth::authorize('admin');
        $body = Request::jsonBody();
        $status = $body['status'] ?? '';
        if (!in_array($status, ['approved', 'rejected', 'completed'], true)) {
            Response::error('Invalid status', 400);
        }

        if ($status === 'rejected') {
            $w = Database::queryGet('SELECT reseller_id, amount FROM withdrawals WHERE id = ?', [$params['id']]);
            if ($w) {
                Database::queryRun(
                    'UPDATE reseller_profiles SET wallet_balance = wallet_balance + ? WHERE id = ?',
                    [$w['amount'], $w['reseller_id']]
                );
            }
        }

        Database::queryRun(
            "UPDATE withdrawals SET status = ?, processed_at = NOW() WHERE id = ?",
            [$status, $params['id']]
        );
        Response::json(['message' => "Withdrawal $status"]);
    }
}
