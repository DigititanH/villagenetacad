<?php

/**
 * Marks an order paid, decrements stock, and credits reseller commissions.
 *
 * Locked splits (meeting):
 * - Independent VNA-B (no academy): seller 53% · Digititan rest
 * - Affiliated VNA-B (academy set): seller 53% · centre 26% · Digititan 21%
 * - Centre VNA-C: centre 26% · Digititan rest
 *
 * Does not touch PayFast / ITN — only called after payment is confirmed.
 */
class OrderFulfillment
{
    private const SELLER_PCT = 53.0;
    private const CENTRE_PCT = 26.0;
    private const DIGITITAN_AFFILIATED_PCT = 21.0;

    public static function fulfill(int $orderId): ?array
    {
        $order = Database::queryGet('SELECT * FROM orders WHERE id = ?', [$orderId]);
        if (!$order) {
            throw new RuntimeException('Order not found');
        }
        if ($order['payment_status'] === 'paid') {
            return $order;
        }

        $items = Database::queryAll(
            'SELECT oi.*, p.name, p.stock FROM order_items oi
             JOIN products p ON p.id = oi.product_id WHERE oi.order_id = ?',
            [$orderId]
        );

        foreach ($items as $item) {
            if ((int) $item['stock'] < (int) $item['quantity']) {
                throw new RuntimeException($item['name'] . ' is out of stock');
            }
            Database::queryRun(
                'UPDATE products SET stock = stock - ? WHERE id = ?',
                [$item['quantity'], $item['product_id']]
            );
        }

        self::creditCommissions($order);

        Database::queryRun(
            "UPDATE orders SET payment_status = 'paid', status = 'processing', updated_at = NOW() WHERE id = ?",
            [$orderId]
        );
        Database::queryRun('DELETE FROM cart WHERE user_id = ?', [$order['user_id']]);

        self::markClientBought($order);

        $user = Database::queryGet(
            'SELECT r.name, l.email FROM registrations r
             JOIN logins l ON l.registration_id = r.id WHERE r.id = ?',
            [$order['user_id']]
        );
        if ($user) {
            $itemsList = implode('<br>', array_map(
                fn ($i) => $i['name'] . ' × ' . $i['quantity'] . ' (R' . number_format($i['price'] * $i['quantity'], 2) . ')',
                $items
            ));
            Mailer::send([
                'to' => Site::email(),
                'replyTo' => $user['email'],
                'subject' => 'Paid order #' . $orderId . ' — R' . number_format((float) $order['total'], 2),
                'html' => '<p><strong>Customer:</strong> ' . htmlspecialchars($user['name']) . ' (' . htmlspecialchars($user['email']) . ')</p>
                    <p><strong>Order ID:</strong> ' . $orderId . '</p>
                    <p><strong>Total paid:</strong> R' . number_format((float) $order['total'], 2) . '</p>
                    <p><strong>Items:</strong><br>' . $itemsList . '</p>',
            ]);
        }

        return Database::queryGet('SELECT * FROM orders WHERE id = ?', [$orderId]);
    }

    private static function creditCommissions(array $order): void
    {
        $orderId = (int) $order['id'];
        $total = (float) $order['total'];
        $code = trim($order['referral_code'] ?? '');
        if ($code === '' || $total <= 0) {
            return;
        }

        // Idempotent: any commission row for this order means already credited.
        $existing = Database::queryGet('SELECT id FROM commissions WHERE order_id = ? LIMIT 1', [$orderId]);
        if ($existing) {
            return;
        }

        $seller = Database::queryGet(
            "SELECT id, referral_code, commission_rate, academy
             FROM reseller_profiles
             WHERE referral_code = ? AND status = 'approved'",
            [$code]
        );
        if (!$seller) {
            return;
        }

        $ref = strtoupper(trim((string) $seller['referral_code']));
        $isCentreCode = strpos($ref, 'VNA-C-') === 0;
        $academy = trim((string) ($seller['academy'] ?? ''));
        $affiliated = !$isCentreCode && $academy !== '';

        // Seller / centre cut on this sale.
        $sellerPct = $isCentreCode
            ? self::CENTRE_PCT
            : (float) ($seller['commission_rate'] ?: self::SELLER_PCT);
        if ($sellerPct <= 0) {
            $sellerPct = $isCentreCode ? self::CENTRE_PCT : self::SELLER_PCT;
        }

        self::creditParty(
            (int) $seller['id'],
            $orderId,
            $total,
            $sellerPct,
            $isCentreCode ? 'centre' : 'seller'
        );

        $digititanPct = 100.0 - $sellerPct;

        if ($affiliated) {
            $centre = self::findCentreByAcademy($academy);
            if ($centre && (int) $centre['id'] !== (int) $seller['id']) {
                self::creditParty(
                    (int) $centre['id'],
                    $orderId,
                    $total,
                    self::CENTRE_PCT,
                    'centre'
                );
                $digititanPct = self::DIGITITAN_AFFILIATED_PCT;
            }
        }

        // Digititan share is ledger-only (no wallet). Attribute to seller row for audit.
        if ($digititanPct > 0) {
            self::insertCommissionRow(
                (int) $seller['id'],
                $orderId,
                round($total * ($digititanPct / 100), 2),
                'digititan',
                $digititanPct,
                false
            );
        }
    }

    private static function creditParty(
        int $resellerId,
        int $orderId,
        float $orderTotal,
        float $percent,
        string $party
    ): void {
        $amount = round($orderTotal * ($percent / 100), 2);
        if ($amount <= 0) {
            return;
        }
        self::insertCommissionRow($resellerId, $orderId, $amount, $party, $percent, true);
    }

    private static function insertCommissionRow(
        int $resellerId,
        int $orderId,
        float $amount,
        string $party,
        float $percent,
        bool $creditWallet
    ): void {
        if ($amount <= 0) {
            return;
        }

        // party column may be missing on old DBs — try with party, fall back without.
        try {
            Database::queryRun(
                'INSERT INTO commissions (reseller_id, order_id, amount, party, share_percent) VALUES (?, ?, ?, ?, ?)',
                [$resellerId, $orderId, $amount, $party, $percent]
            );
        } catch (Throwable $e) {
            if ($party === 'digititan') {
                // Old schema: skip digititan row (statement can still estimate).
                return;
            }
            Database::queryRun(
                'INSERT INTO commissions (reseller_id, order_id, amount) VALUES (?, ?, ?)',
                [$resellerId, $orderId, $amount]
            );
        }

        if ($creditWallet) {
            Database::queryRun(
                'UPDATE reseller_profiles SET wallet_balance = wallet_balance + ?, total_earned = total_earned + ? WHERE id = ?',
                [$amount, $amount, $resellerId]
            );
        }
    }

    /** Match affiliated academy name to an approved VNA-C centre profile. */
    private static function findCentreByAcademy(string $academy): ?array
    {
        $name = trim($academy);
        if ($name === '') {
            return null;
        }

        return Database::queryGet(
            "SELECT rp.id, rp.referral_code, rp.commission_rate, rp.academy
             FROM reseller_profiles rp
             JOIN registrations r ON r.id = rp.user_id
             WHERE rp.status = 'approved'
               AND UPPER(rp.referral_code) LIKE 'VNA-C-%'
               AND (
                 LOWER(TRIM(COALESCE(rp.academy, ''))) = LOWER(?)
                 OR LOWER(TRIM(r.name)) = LOWER(?)
               )
             ORDER BY rp.id ASC
             LIMIT 1",
            [$name, $name]
        ) ?: null;
    }

    /** If reseller listed this buyer as a client, mark bought. */
    private static function markClientBought(array $order): void
    {
        $code = trim($order['referral_code'] ?? '');
        if ($code === '') {
            return;
        }

        $seller = Database::queryGet(
            "SELECT id FROM reseller_profiles WHERE referral_code = ? AND status = 'approved'",
            [$code]
        );
        if (!$seller) {
            return;
        }

        $buyer = Database::queryGet(
            'SELECT l.email FROM logins l WHERE l.registration_id = ?',
            [$order['user_id']]
        );
        $email = strtolower(trim((string) ($buyer['email'] ?? '')));
        if ($email === '') {
            return;
        }

        try {
            Database::queryRun(
                "UPDATE reseller_clients
                 SET status = 'bought', updated_at = NOW()
                 WHERE reseller_id = ? AND LOWER(email) = ?",
                [(int) $seller['id'], $email]
            );
        } catch (Throwable $e) {
            // Table may not exist yet on live — ignore.
        }
    }
}
