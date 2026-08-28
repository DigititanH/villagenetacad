<?php

/**
 * Transactional emails for the mobile app (APP_SMTP / channel=app).
 * Complements InAppNotifications — same events, inbox + email.
 */
class AppEmails
{
    private static function siteUrl(): string
    {
        return rtrim((string) Client::getClientUrl(), '/');
    }

    private static function sendApp(string $to, string $subject, string $html): void
    {
        if ($to === '' || $subject === '') {
            return;
        }
        try {
            Mailer::send([
                'to' => $to,
                'subject' => $subject,
                'html' => $html,
                'channel' => 'app',
            ]);
        } catch (Throwable $e) {
            error_log('[AppEmails] ' . $e->getMessage());
        }
    }

    public static function welcomeCustomer(string $name, string $email): void
    {
        $safeName = htmlspecialchars($name);
        $safeEmail = htmlspecialchars($email);
        $site = self::siteUrl();
        self::sendApp(
            $email,
            'Welcome to Village NetAcad',
            "<h2>Welcome, {$safeName}!</h2>
            <p>Your Village NetAcad account is ready.</p>
            <p><strong>Email:</strong> {$safeEmail}</p>
            <p>You can sign in on the <strong>Village NetAcad</strong> app and on the website with this email right away.</p>
            <h3>What you can do</h3>
            <ul>
              <li><strong>Shop</strong> — browse kit and merch in the app, then complete checkout on the website (PayFast).</li>
              <li><strong>Training</strong> — free Cisco NetAcad skills courses and the paid CCNA pathway via the website.</li>
              <li><strong>Academies</strong> — explore academy / NPO pathways on the site and in the app.</li>
              <li><strong>Reseller</strong> — apply from the app when you are ready; approved sellers receive a referral code and wallet.</li>
            </ul>
            <p>Website: <a href=\"{$site}\">{$site}</a></p>
            <p>Questions? Reply to this email or write to <a href=\"mailto:info@villagenetacad.co.za\">info@villagenetacad.co.za</a>.</p>
            <p>— Village NetAcad · Powered by Digititan</p>"
        );
    }

    /** After reseller applies from the mobile app (pending review). */
    public static function welcomeResellerPending(string $name, string $email): void
    {
        $safeName = htmlspecialchars($name);
        $safeEmail = htmlspecialchars($email);
        $site = self::siteUrl();
        self::sendApp(
            $email,
            'We have received your Village NetAcad reseller application',
            "<h2>Thank you, {$safeName}</h2>
            <p>We have received your application to become a Village NetAcad reseller.</p>
            <p><strong>Email:</strong> {$safeEmail}</p>
            <p>We are reviewing your application. You will receive another email from us once you have been approved, including your referral code and guidance on how to get started.</p>
            <p>Until then, you will not be able to sign in as a reseller. No further action is required from you right now.</p>
            <p>Website: <a href=\"{$site}\">{$site}</a></p>
            <p>Questions? Reply to this email or write to <a href=\"mailto:info@villagenetacad.co.za\">info@villagenetacad.co.za</a>.</p>
            <p>— Village NetAcad · Powered by Digititan</p>"
        );
    }

    /** When admin approves a reseller profile. */
    public static function resellerApproved(int $userId): void
    {
        $row = Database::queryGet(
            'SELECT r.name, l.email, rp.referral_code, rp.commission_rate, rp.academy
             FROM registrations r
             JOIN logins l ON l.registration_id = r.id
             JOIN reseller_profiles rp ON rp.user_id = r.id
             WHERE r.id = ?',
            [$userId]
        );
        if (!$row || empty($row['email'])) {
            return;
        }

        $safeName = htmlspecialchars((string) $row['name']);
        $code = htmlspecialchars((string) $row['referral_code']);
        $rate = number_format((float) ($row['commission_rate'] ?: 0), 0);
        $ref = strtoupper(trim((string) $row['referral_code']));
        $isCentre = strpos($ref, 'VNA-C-') === 0;
        $pathLine = $isCentre
            ? 'Your centre code starts with <strong>VNA-C</strong>. Approved centre sales typically earn <strong>26%</strong> of the order total (Digititan retains the rest).'
            : 'Your seller code starts with <strong>VNA-B</strong>. Approved sellers typically earn <strong>53%</strong> of the order total'
              . (trim((string) ($row['academy'] ?? '')) !== ''
                  ? ', with a centre share and Digititan programme share on affiliated sales.'
                  : ' (Digititan retains the rest on independent sales).');

        $site = self::siteUrl();
        self::sendApp(
            (string) $row['email'],
            'Your Village NetAcad reseller account is approved',
            "<h2>Congratulations, {$safeName}</h2>
            <p>We have approved your reseller application. You can now sign in to the Village NetAcad app as a reseller.</p>
            <p><strong>Your referral code:</strong> <code style=\"font-size:1.1em\">{$code}</code></p>
            <p><strong>Your commission rate:</strong> {$rate}%</p>
            <p>{$pathLine}</p>
            <h3>How reselling works</h3>
            <ol>
              <li>Share your referral code (and QR / verify link in the app) with customers.</li>
              <li>When they check out with your code and payment is confirmed, commission is credited to your wallet.</li>
              <li>Open the app → <strong>Reseller dashboard</strong> to see your wallet balance, clients, and monthly earnings statement.</li>
              <li>Withdrawals are available on the last calendar day of the month (minimum R100), subject to approval.</li>
            </ol>
            <p>Explore the store, training, and academies in the app while you grow your network — the same login works on the website too.</p>
            <p>Website: <a href=\"{$site}\">{$site}</a></p>
            <p>— Village NetAcad · Powered by Digititan</p>"
        );

        InAppNotifications::notify(
            $userId,
            'Reseller approved',
            "Your reseller account is approved. Referral code: {$row['referral_code']}. Open your reseller dashboard to get started.",
            'success'
        );
    }

    /** Buyer confirmation after payment. */
    public static function orderPaidCustomer(array $order, array $items, array $buyer): void
    {
        $email = (string) ($buyer['email'] ?? '');
        if ($email === '') {
            return;
        }
        $orderId = (int) ($order['id'] ?? 0);
        $total = number_format((float) ($order['total'] ?? 0), 2);
        $status = htmlspecialchars((string) ($order['status'] ?? 'processing'));
        $safeName = htmlspecialchars((string) ($buyer['name'] ?? 'Customer'));
        $itemsList = self::itemsHtml($items);
        $code = trim((string) ($order['referral_code'] ?? ''));
        $refLine = $code !== ''
            ? '<p><strong>Referral code used:</strong> ' . htmlspecialchars($code) . '</p>'
            : '';

        self::sendApp(
            $email,
            "Order #{$orderId} confirmed — Village NetAcad",
            "<h2>Thank you for your purchase, {$safeName}</h2>
            <p>We have received payment for your order. Here are your details:</p>
            <p><strong>Order number:</strong> #{$orderId}<br>
               <strong>Amount paid:</strong> R{$total}<br>
               <strong>Status:</strong> {$status}</p>
            {$refLine}
            <p><strong>Items:</strong></p>
            {$itemsList}
            <p>You can track this order anytime in the Village NetAcad app under <strong>Profile → My orders</strong>. We will email you again when the status changes (for example processing, shipped, or delivered).</p>
            <p>— Village NetAcad · Powered by Digititan</p>"
        );
    }

    /** Seller / centre when a referral code is used on a paid order. */
    public static function orderPaidResellerParty(
        int $resellerUserId,
        string $referralCode,
        string $partyLabel,
        array $order,
        array $items,
        ?float $commissionAmount = null
    ): void {
        $user = Database::queryGet(
            'SELECT r.name, l.email FROM registrations r
             JOIN logins l ON l.registration_id = r.id WHERE r.id = ?',
            [$resellerUserId]
        );
        if (!$user || empty($user['email'])) {
            return;
        }

        $orderId = (int) ($order['id'] ?? 0);
        $total = number_format((float) ($order['total'] ?? 0), 2);
        $safeName = htmlspecialchars((string) $user['name']);
        $code = htmlspecialchars($referralCode);
        $label = htmlspecialchars($partyLabel);
        $earn = $commissionAmount !== null
            ? '<p><strong>Your share on this order:</strong> R' . number_format($commissionAmount, 2) . '</p>'
            : '';
        $itemsList = self::itemsHtml($items);

        self::sendApp(
            (string) $user['email'],
            "Sale attributed to {$referralCode} — order #{$orderId}",
            "<h2>Hello {$safeName}</h2>
            <p>A customer has completed a purchase using your referral code <strong>{$code}</strong> ({$label}).</p>
            <p><strong>Order number:</strong> #{$orderId}<br>
               <strong>Order total:</strong> R{$total}</p>
            {$earn}
            <p><strong>Items:</strong></p>
            {$itemsList}
            <p>Open the Village NetAcad app → <strong>Reseller dashboard</strong> to view your wallet balance and earnings statement for the full picture of what you have earned.</p>
            <p>— Village NetAcad · Powered by Digititan</p>"
        );
    }

    /** Buyer when Ops updates order status / tracking. */
    public static function orderStatusCustomer(
        array $order,
        string $newStatus,
        ?string $tracking = null
    ): void {
        $userId = (int) ($order['user_id'] ?? 0);
        $user = Database::queryGet(
            'SELECT r.name, l.email FROM registrations r
             JOIN logins l ON l.registration_id = r.id WHERE r.id = ?',
            [$userId]
        );
        if (!$user || empty($user['email'])) {
            return;
        }

        $orderId = (int) ($order['id'] ?? 0);
        $safeName = htmlspecialchars((string) $user['name']);
        $label = self::statusLabel($newStatus);
        $track = $tracking ? '<p><strong>Tracking number:</strong> ' . htmlspecialchars($tracking) . '</p>' : '';
        $extra = '';
        $st = strtolower($newStatus);
        if ($st === 'processing') {
            $extra = '<p>We are preparing your order.</p>';
        } elseif ($st === 'shipped') {
            $extra = '<p>Your order is on its way.</p>';
        } elseif ($st === 'delivered') {
            $extra = '<p>We hope you enjoy your purchase. You can leave a review in the app under <strong>My orders</strong>.</p>';
        } elseif ($st === 'cancelled') {
            $extra = '<p>If you did not expect this change, please contact us at <a href="mailto:info@villagenetacad.co.za">info@villagenetacad.co.za</a>.</p>';
        }

        self::sendApp(
            (string) $user['email'],
            "Order #{$orderId} update: {$label}",
            "<h2>Hello {$safeName}</h2>
            <p>We have an update on your Village NetAcad order <strong>#{$orderId}</strong>.</p>
            <p><strong>New status:</strong> {$label}</p>
            {$track}
            {$extra}
            <p>View full details anytime in the app under <strong>Profile → My orders</strong>.</p>
            <p>— Village NetAcad · Powered by Digititan</p>"
        );
    }

    /** @param array<int,array<string,mixed>> $items */
    private static function itemsHtml(array $items): string
    {
        if ($items === []) {
            return '<p>—</p>';
        }
        $rows = array_map(static function ($i) {
            $name = htmlspecialchars((string) ($i['name'] ?? 'Item'));
            $qty = (int) ($i['quantity'] ?? 1);
            $line = number_format((float) ($i['price'] ?? 0) * $qty, 2);
            return "<li>{$name} × {$qty} — R{$line}</li>";
        }, $items);
        return '<ul>' . implode('', $rows) . '</ul>';
    }

    private static function statusLabel(string $status): string
    {
        $map = [
            'pending' => 'Pending',
            'processing' => 'Processing',
            'shipped' => 'Shipped',
            'delivered' => 'Delivered',
            'cancelled' => 'Cancelled',
            'canceled' => 'Cancelled',
        ];
        $key = strtolower(trim($status));
        return $map[$key] ?? ucfirst(str_replace('_', ' ', $status));
    }
}
