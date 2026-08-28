<?php

/**
 * In-app notifications only (no SMTP / push).
 * Rows land in `notifications` and show in Profile → Notifications.
 */
class InAppNotifications
{
    public static function notify(
        int $userId,
        string $title,
        string $message,
        string $type = 'info'
    ): void {
        if ($userId < 1) {
            return;
        }
        $allowed = ['info', 'success', 'warning', 'error'];
        if (!in_array($type, $allowed, true)) {
            $type = 'info';
        }
        $title = substr(trim($title), 0, 255);
        $message = trim($message);
        if ($title === '' || $message === '') {
            return;
        }

        try {
            Database::queryRun(
                'INSERT INTO notifications (user_id, title, message, type, is_read) VALUES (?, ?, ?, ?, 0)',
                [$userId, $title, $message, $type]
            );
        } catch (Throwable $e) {
            error_log('InAppNotifications: ' . $e->getMessage());
        }
    }

    /** After PayFast / fulfill marks an order paid. */
    public static function orderPaid(array $order, array $items = []): void
    {
        $orderId = (int) ($order['id'] ?? 0);
        $userId = (int) ($order['user_id'] ?? 0);
        $total = number_format((float) ($order['total'] ?? 0), 2);
        $itemNames = [];
        foreach ($items as $item) {
            if (!empty($item['name'])) {
                $itemNames[] = $item['name'];
            }
        }
        $itemsLine = $itemNames ? implode(', ', array_slice($itemNames, 0, 3)) : 'your items';

        self::notify(
            $userId,
            'Payment confirmed',
            "Order #$orderId is paid (R$total). We are processing $itemsLine.",
            'success'
        );

        $code = trim((string) ($order['referral_code'] ?? ''));
        if ($code === '') {
            return;
        }

        $seller = Database::queryGet(
            "SELECT id, user_id, referral_code, academy FROM reseller_profiles
             WHERE referral_code = ? AND status = 'approved'",
            [$code]
        );
        if (!$seller) {
            return;
        }

        self::notify(
            (int) $seller['user_id'],
            'Reseller sale confirmed',
            "A sale on order #$orderId (R$total) was attributed to {$seller['referral_code']}. Check your wallet and statement.",
            'success'
        );

        $ref = strtoupper(trim((string) $seller['referral_code']));
        $isCentre = strpos($ref, 'VNA-C-') === 0;
        $academy = trim((string) ($seller['academy'] ?? ''));
        if ($isCentre || $academy === '') {
            return;
        }

        $centre = Database::queryGet(
            "SELECT rp.user_id, rp.referral_code
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
            [$academy, $academy]
        );
        if ($centre && (int) $centre['user_id'] !== (int) $seller['user_id']) {
            self::notify(
                (int) $centre['user_id'],
                'Centre share earned',
                "Order #$orderId (R$total) credited a centre share to {$centre['referral_code']}.",
                'success'
            );
        }
    }

    /** After Ops changes order status / tracking. */
    public static function orderStatusChanged(
        array $order,
        ?string $oldStatus,
        ?string $newStatus,
        ?string $tracking = null
    ): void {
        $orderId = (int) ($order['id'] ?? 0);
        $userId = (int) ($order['user_id'] ?? 0);
        if ($userId < 1 || $newStatus === null || $newStatus === '') {
            return;
        }
        if ($oldStatus !== null && strcasecmp((string) $oldStatus, $newStatus) === 0 && !$tracking) {
            return;
        }

        $label = ucfirst(str_replace('_', ' ', $newStatus));
        $body = "Order #$orderId is now: $label.";
        if ($tracking) {
            $body .= " Tracking: $tracking.";
        }
        if (strcasecmp($newStatus, 'delivered') === 0) {
            $body .= ' You can leave a review in My orders.';
        }

        self::notify($userId, 'Order update', $body, 'info');
    }
}
