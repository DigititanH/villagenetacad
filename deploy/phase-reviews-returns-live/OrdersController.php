<?php

class OrdersController
{
    public static function create(): void
    {
        Auth::authenticate();
        $body = Request::jsonBody();
        $items = $body['items'] ?? [];
        $shippingAddress = $body['shipping_address'] ?? null;
        $referralCode = trim((string) ($body['referral_code'] ?? ''));

        if (!$items || !$shippingAddress) {
            Response::error('Items and shipping address are required', 400);
        }

        $reseller = null;
        if (Auth::$user['role'] !== 'admin') {
            if ($referralCode === '') {
                Response::error('A reseller referral code is required to place an order', 400);
            }
            $reseller = Database::queryGet(
                "SELECT id, commission_rate FROM reseller_profiles WHERE referral_code = ? AND status = 'approved'",
                [$referralCode]
            );
            if (!$reseller) {
                Response::error('Invalid or inactive reseller referral code', 400);
            }
        } elseif ($referralCode !== '') {
            $reseller = Database::queryGet(
                "SELECT id, commission_rate FROM reseller_profiles WHERE referral_code = ? AND status = 'approved'",
                [$referralCode]
            );
        }

        $total = 0.0;
        $orderItems = [];

        foreach ($items as $item) {
            $product = Database::queryGet(
                'SELECT id, price, stock, name FROM products WHERE id = ? AND is_active = 1',
                [$item['product_id']]
            );
            if (!$product) {
                Response::error('Product ' . ($item['product_id'] ?? '') . ' not found', 400);
            }
            if ((int) $product['stock'] < (int) $item['quantity']) {
                Response::error($product['name'] . ' is out of stock', 400);
            }
            $lineTotal = (float) $product['price'] * (int) $item['quantity'];
            $total += $lineTotal;
            $orderItems[] = array_merge($item, [
                'price' => $product['price'],
                'name' => $product['name'],
            ]);
        }

        $payfastEnabled = Payfast::isConfigured();
        $order = Database::queryRun(
            "INSERT INTO orders (user_id, total, shipping_address, payment_status, referral_code) VALUES (?, ?, ?, 'pending', ?)",
            [Auth::$user['id'], $total, json_encode($shippingAddress), $referralCode ?: null]
        );
        $orderId = $order['lastInsertRowid'];

        foreach ($orderItems as $item) {
            Database::queryRun(
                'INSERT INTO order_items (order_id, product_id, quantity, price, size, color) VALUES (?, ?, ?, ?, ?, ?)',
                [
                    $orderId,
                    $item['product_id'],
                    $item['quantity'],
                    $item['price'],
                    $item['size'] ?? null,
                    $item['color'] ?? null,
                ]
            );
        }

        if ($payfastEnabled) {
            Response::json([
                'order_id' => $orderId,
                'total' => $total,
                'payfast' => true,
                'message' => 'Order created. Redirecting to PayFast for payment.',
            ], 201);
        }

        OrderFulfillment::fulfill($orderId);
        Response::json([
            'order_id' => $orderId,
            'total' => $total,
            'payfast' => false,
            'message' => 'Order placed successfully.',
        ], 201);
    }

    public static function myOrders(): void
    {
        Auth::authenticate();
        $orders = Database::queryAll(
            'SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC',
            [Auth::$user['id']]
        );
        foreach ($orders as &$order) {
            $order = self::enrichOrder($order);
        }
        unset($order);
        Response::json($orders);
    }

    public static function adminAll(): void
    {
        Auth::authorize('admin');
        $status = Request::query('status');
        $page = max(1, (int) Request::query('page', 1));
        $limit = max(1, (int) Request::query('limit', 20));

        $sql = 'SELECT o.*, r.name as customer_name, l.email as customer_email
                FROM orders o
                JOIN registrations r ON o.user_id = r.id
                JOIN logins l ON l.registration_id = r.id';
        $params = [];
        if ($status) {
            $sql .= ' WHERE o.status = ?';
            $params[] = $status;
        }
        $sql .= ' ORDER BY o.created_at DESC LIMIT ? OFFSET ?';
        $params[] = $limit;
        $params[] = ($page - 1) * $limit;

        $orders = Database::queryAll($sql, $params);
        $countResult = Database::queryGet('SELECT COUNT(*) as total FROM orders');
        Response::json(['orders' => $orders, 'total' => (int) ($countResult['total'] ?? 0)]);
    }

    public static function show(array $params): void
    {
        Auth::authenticate();
        $order = Database::queryGet('SELECT * FROM orders WHERE id = ?', [$params['id']]);
        if (!$order) {
            Response::error('Order not found', 404);
        }
        if (Auth::$user['role'] !== 'admin' && (int) $order['user_id'] !== (int) Auth::$user['id']) {
            Response::error('Access denied', 403);
        }
        Response::json(self::enrichOrder($order));
    }

    public static function update(array $params): void
    {
        Auth::authorize('admin');
        $body = Request::jsonBody();
        $orderId = (int) $params['id'];
        $before = Database::queryGet('SELECT * FROM orders WHERE id = ?', [$orderId]);
        if (!$before) {
            Response::error('Order not found', 404);
        }

        $fields = [];
        $sqlParams = [];

        if (!empty($body['status'])) {
            $fields[] = 'status = ?';
            $sqlParams[] = $body['status'];
            if (strcasecmp((string) $body['status'], 'delivered') === 0
                && empty($before['delivered_at'])) {
                $fields[] = 'delivered_at = NOW()';
            }
        }
        if (!empty($body['tracking_number'])) {
            $fields[] = 'tracking_number = ?';
            $sqlParams[] = $body['tracking_number'];
        }

        if (!$fields) {
            Response::error('Nothing to update', 400);
        }

        $sqlParams[] = $orderId;
        Database::queryRun('UPDATE orders SET ' . implode(', ', $fields) . ' WHERE id = ?', $sqlParams);

        $after = Database::queryGet('SELECT * FROM orders WHERE id = ?', [$orderId]);
        $newStatus = $body['status'] ?? ($before['status'] ?? null);
        $tracking = isset($body['tracking_number']) ? (string) $body['tracking_number'] : null;
        InAppNotifications::orderStatusChanged(
            $after ?: $before,
            $before['status'] ?? null,
            $newStatus,
            $tracking
        );
        if (!empty($newStatus)) {
            $old = (string) ($before['status'] ?? '');
            $changed = strcasecmp($old, (string) $newStatus) !== 0 || $tracking;
            if ($changed) {
                AppEmails::orderStatusCustomer(
                    $after ?: $before,
                    (string) $newStatus,
                    $tracking
                );
            }
        }

        Response::json(['message' => 'Order updated']);
    }

    /** Customer: leave a star review for products on a delivered order. */
    public static function submitReview(array $params): void
    {
        Auth::authenticate();
        $orderId = (int) $params['id'];
        $order = Database::queryGet('SELECT * FROM orders WHERE id = ?', [$orderId]);
        if (!$order) {
            Response::error('Order not found', 404);
        }
        if ((int) $order['user_id'] !== (int) Auth::$user['id']) {
            Response::error('Access denied', 403);
        }

        $status = strtolower((string) ($order['status'] ?? ''));
        $deliveredAt = $order['delivered_at'] ?? null;
        $canReview = $deliveredAt
            && in_array($status, ['delivered', 'return_requested'], true);
        if (!$canReview) {
            Response::error('You can only review a delivered order', 400);
        }

        $body = Request::jsonBody();
        $rating = (int) ($body['rating'] ?? $body['stars'] ?? 0);
        $comment = trim((string) ($body['comment'] ?? $body['text'] ?? ''));
        if ($rating < 1 || $rating > 5) {
            Response::error('Rating must be 1-5', 400);
        }

        $items = Database::queryAll(
            'SELECT DISTINCT product_id FROM order_items WHERE order_id = ? AND product_id IS NOT NULL',
            [$orderId]
        );
        if (!$items) {
            Response::error('This order has no products to review', 400);
        }

        foreach ($items as $item) {
            $productId = (int) $item['product_id'];
            if ($productId < 1) {
                continue;
            }
            $existing = Database::queryGet(
                'SELECT id FROM reviews WHERE user_id = ? AND product_id = ?',
                [Auth::$user['id'], $productId]
            );
            if ($existing) {
                Database::queryRun(
                    'UPDATE reviews SET rating = ?, comment = ? WHERE id = ?',
                    [$rating, $comment !== '' ? $comment : null, $existing['id']]
                );
            } else {
                Database::queryRun(
                    'INSERT INTO reviews (user_id, product_id, rating, comment) VALUES (?, ?, ?, ?)',
                    [Auth::$user['id'], $productId, $rating, $comment !== '' ? $comment : null]
                );
            }
        }

        InAppNotifications::notify(
            (int) Auth::$user['id'],
            'Review submitted',
            "Thank you for reviewing order #{$orderId}.",
            'success'
        );

        $fresh = Database::queryGet('SELECT * FROM orders WHERE id = ?', [$orderId]);
        Response::json(self::enrichOrder($fresh ?: $order), 201);
    }

    /** Customer: request a return within 7 days of delivery. */
    public static function requestReturn(array $params): void
    {
        Auth::authenticate();
        $orderId = (int) $params['id'];
        $order = Database::queryGet('SELECT * FROM orders WHERE id = ?', [$orderId]);
        if (!$order) {
            Response::error('Order not found', 404);
        }
        if ((int) $order['user_id'] !== (int) Auth::$user['id']) {
            Response::error('Access denied', 403);
        }

        $status = strtolower((string) ($order['status'] ?? ''));
        if ($status === 'return_requested') {
            Response::error('A return has already been requested for this order', 409);
        }
        if ($status !== 'delivered') {
            Response::error('Returns are only available after delivery', 400);
        }

        $deliveredAt = $order['delivered_at'] ?? null;
        if (!$deliveredAt) {
            Response::error('Delivery date is missing for this order. Please contact support.', 400);
        }
        $deadline = strtotime($deliveredAt . ' +7 days');
        if ($deadline === false || time() > $deadline) {
            Response::error('The 7-day return window has closed', 400);
        }

        $existing = Database::queryGet(
            'SELECT id FROM order_returns WHERE order_id = ?',
            [$orderId]
        );
        if ($existing) {
            Response::error('A return has already been requested for this order', 409);
        }

        $body = Request::jsonBody();
        $reason = trim((string) ($body['reason'] ?? ''));
        if ($reason === '') {
            Response::error('Please describe why you are returning this order', 400);
        }

        Database::queryRun(
            'INSERT INTO order_returns (order_id, user_id, reason, status) VALUES (?, ?, ?, ?)',
            [$orderId, Auth::$user['id'], $reason, 'requested']
        );
        Database::queryRun(
            "UPDATE orders SET status = 'return_requested' WHERE id = ?",
            [$orderId]
        );

        $fresh = Database::queryGet('SELECT * FROM orders WHERE id = ?', [$orderId]);
        AppEmails::returnRequestedCustomer($fresh ?: $order, $reason);
        AppEmails::returnRequestedOps($fresh ?: $order, $reason);
        InAppNotifications::notify(
            (int) Auth::$user['id'],
            'Return requested',
            "We have received your return request for order #{$orderId}. Our team will review it shortly.",
            'info'
        );

        Response::json(self::enrichOrder($fresh ?: $order), 201);
    }

    /** @param array<string,mixed> $order */
    private static function enrichOrder(array $order): array
    {
        $orderId = (int) ($order['id'] ?? 0);
        $userId = (int) ($order['user_id'] ?? 0);

        $order['items'] = Database::queryAll(
            'SELECT oi.*, p.name, p.image
             FROM order_items oi
             LEFT JOIN products p ON p.id = oi.product_id
             WHERE oi.order_id = ?',
            [$orderId]
        );

        $returnRow = null;
        try {
            $returnRow = Database::queryGet(
                'SELECT id, reason, status, created_at FROM order_returns WHERE order_id = ?',
                [$orderId]
            );
        } catch (Throwable $e) {
            $returnRow = null;
        }

        $status = strtolower((string) ($order['status'] ?? ''));
        $order['return_requested'] = $returnRow !== null || $status === 'return_requested';
        if ($returnRow) {
            $order['return'] = $returnRow;
        }

        $review = null;
        try {
            $review = Database::queryGet(
                'SELECT r.rating, r.comment, r.created_at
                 FROM reviews r
                 INNER JOIN order_items oi ON oi.product_id = r.product_id
                 WHERE oi.order_id = ? AND r.user_id = ?
                 ORDER BY r.created_at DESC
                 LIMIT 1',
                [$orderId, $userId]
            );
        } catch (Throwable $e) {
            $review = null;
        }

        $order['reviewed'] = $review !== null;
        if ($review) {
            $order['review_stars'] = (int) ($review['rating'] ?? 0);
            $order['review_text'] = $review['comment'] ?? null;
        }

        if (empty($order['delivered_at'])
            && in_array($status, ['delivered', 'return_requested'], true)) {
            $order['delivered_at'] = $order['updated_at'] ?? $order['created_at'] ?? null;
        }

        return $order;
    }
}
