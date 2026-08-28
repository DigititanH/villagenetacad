<?php

/**
 * PayFast controller — ITN auto-fulfill hardened for live cPanel.
 *
 * Compatible with the richer live lib/Payfast.php (do not need to overwrite Payfast.php).
 * Upload to: public_html/backend-php/controllers/PayfastController.php
 */
class PayfastController
{
    private static function parsePaymentId(string $mPaymentId): ?array
    {
        if (!preg_match('/^(order|donation|ccna)-(\d+)$/', $mPaymentId, $m)) {
            return null;
        }
        return ['type' => $m[1], 'id' => (int) $m[2]];
    }

    private static function itnLog(string $message): void
    {
        if (class_exists('Payfast') && method_exists('Payfast', 'itnLog')) {
            Payfast::itnLog($message);
            return;
        }
        $line = '[' . date('Y-m-d H:i:s') . '] ' . $message . "\n";
        error_log('PayFast ITN: ' . $message);
        $dir = dirname(__DIR__) . '/payfast';
        if (!is_dir($dir)) {
            @mkdir($dir, 0755, true);
        }
        if (is_dir($dir) && is_writable($dir)) {
            @file_put_contents($dir . '/payfast.log', $line, FILE_APPEND | LOCK_EX);
        }
    }

    /** Local signature check — works with live generateSignature($data, $pp, $useAttributeOrder). */
    private static function localSignatureOk(array $data): bool
    {
        if (method_exists('Payfast', 'verifyItnSignature')) {
            return Payfast::verifyItnSignature($data);
        }

        $received = (string) ($data['signature'] ?? '');
        if ($received === '' || !method_exists('Payfast', 'generateSignature')) {
            return false;
        }

        $passphrases = array_values(array_unique([
            method_exists('Payfast', 'passphrase') ? Payfast::passphrase() : '',
            '',
        ]));

        foreach ($passphrases as $pp) {
            // Live API: generateSignature($data, $passphrase = null, $useAttributeOrder = true)
            // false = preserve POST field order (ITN); true = FIELD_ORDER (forms)
            foreach ([false, true] as $useAttributeOrder) {
                try {
                    $expected = Payfast::generateSignature($data, $pp, $useAttributeOrder);
                    if (hash_equals((string) $expected, $received)) {
                        return true;
                    }
                } catch (Throwable $e) {
                    // ignore and try next
                }
            }
            // 2-arg fallback
            try {
                $expected = Payfast::generateSignature($data, $pp);
                if (hash_equals((string) $expected, $received)) {
                    return true;
                }
            } catch (Throwable $e) {
                // ignore
            }
        }
        return false;
    }

    private static function merchantOk(array $data): bool
    {
        if (method_exists('Payfast', 'itnMerchantMatches')) {
            return Payfast::itnMerchantMatches($data);
        }
        $posted = trim((string) ($data['merchant_id'] ?? ''));
        $ours = trim(method_exists('Payfast', 'merchantId') ? (string) Payfast::merchantId() : '');
        return $posted !== '' && $ours !== '' && hash_equals($ours, $posted);
    }

    public static function status(): void
    {
        Response::json(Payfast::statusPayload());
    }

    public static function check(): void
    {
        if (Env::isProduction()) {
            Response::error('Not found', 404);
        }
        if (!Payfast::isConfigured()) {
            Response::json([
                'ok' => false,
                'message' => 'Set PAYFAST_MERCHANT_ID and PAYFAST_MERCHANT_KEY in backend-php/.env',
            ], 503);
        }

        $notifyUrl = Payfast::getNotifyUrl();
        $sample = Payfast::buildPaymentPayload([
            'amount' => 50,
            'itemName' => 'Test Payment',
            'paymentId' => 'donation-test',
            'email' => 'test@example.com',
            'name' => 'Test User',
            'returnPath' => '/payment/success?type=donation&id=1',
            'cancelPath' => '/payment/cancel?type=donation&id=1',
        ]);

        $warnings = [];
        $blockers = [];

        if (Payfast::isNotifyUrlLocal($notifyUrl)) {
            $warnings[] = 'notify_url uses localhost — payments may work, but PayFast cannot confirm them.';
        }
        if (Payfast::passphrase() !== '') {
            $warnings[] = 'Passphrase is set — it must match PayFast → Settings → Security exactly.';
        }

        $probe = method_exists('Payfast', 'probeCredentials') ? Payfast::probeCredentials() : [];
        Response::json([
            'ok' => count($blockers) === 0,
            'sandbox' => Payfast::isSandbox(),
            'merchant_id' => Payfast::merchantId(),
            'has_passphrase' => Payfast::passphrase() !== '',
            'notify_url' => $notifyUrl,
            'warnings' => $warnings,
            'blockers' => $blockers,
            'probe' => $probe,
            'sample_signature' => $sample['signature'] ?? null,
        ]);
    }

    public static function handlePay(): void
    {
        if (!Payfast::isConfigured()) {
            Response::error('PayFast is not configured on the server', 503);
        }

        $body = Request::jsonBody();
        $amount = $body['amount'] ?? null;
        $itemName = $body['item_name'] ?? '';
        $nameFirst = $body['name_first'] ?? '';
        $email = $body['email_address'] ?? '';
        $nameLast = $body['name_last'] ?? '';
        $paymentId = $body['m_payment_id'] ?? null;
        $returnUrl = $body['return_url'] ?? null;
        $cancelUrl = $body['cancel_url'] ?? null;

        if (!$amount || !$itemName || !$nameFirst || !$email) {
            Response::error('amount, item_name, name_first, and email_address are required', 400);
        }

        $fullName = $nameLast ? trim("$nameFirst $nameLast") : trim((string) $nameFirst);

        $fields = Payfast::buildPaymentPayload([
            'amount' => $amount,
            'itemName' => $itemName,
            'paymentId' => $paymentId,
            'email' => $email,
            'name' => $fullName,
            'returnUrl' => $returnUrl,
            'cancelUrl' => $cancelUrl,
        ]);

        $fields = array_map(static fn ($v) => is_scalar($v) ? (string) $v : $v, $fields);

        Response::json(['url' => Payfast::processUrl(), 'fields' => $fields]);
    }

    public static function debugSignature(): void
    {
        if (Env::isProduction()) {
            Response::error('Not found', 404);
        }
        $sample = Payfast::buildPaymentPayload([
            'amount' => 50,
            'itemName' => 'Test',
            'paymentId' => 'donation-1',
            'email' => 'test@test.com',
            'name' => 'Test User',
            'returnPath' => '/payment/success?type=donation&id=1',
            'cancelPath' => '/payment/cancel?type=donation&id=1',
        ]);
        $hidden = $sample;
        $hidden['signature'] = '[hidden]';
        Response::json([
            'signature_string' => method_exists('Payfast', 'buildSignatureString')
                ? Payfast::buildSignatureString($sample)
                : null,
            'signature' => $sample['signature'] ?? null,
            'fields' => $hidden,
        ]);
    }

    public static function orderPayment(array $params): void
    {
        if (!Payfast::isConfigured()) {
            Response::error('PayFast is not configured on the server', 503);
        }
        Auth::authenticate();

        $orderId = (int) $params['orderId'];
        $order = Database::queryGet('SELECT * FROM orders WHERE id = ?', [$orderId]);
        if (!$order) {
            Response::error('Order not found', 404);
        }
        if ((int) $order['user_id'] !== (int) Auth::$user['id'] && Auth::$user['role'] !== 'admin') {
            Response::error('Access denied', 403);
        }
        if ($order['payment_status'] === 'paid') {
            Response::error('Order is already paid', 400);
        }

        try {
            $fields = Payfast::buildPaymentPayload([
                'amount' => $order['total'],
                'itemName' => "Village Netacad Order $orderId",
                'paymentId' => "order-$orderId",
                'email' => Auth::$user['email'],
                'name' => Auth::$user['name'],
                'returnPath' => "/payment/success?type=order&id=$orderId",
                'cancelPath' => "/payment/cancel?type=order&id=$orderId",
            ]);
        } catch (Throwable $e) {
            Response::error($e->getMessage(), 400);
        }

        Response::json(['url' => Payfast::processUrl(), 'fields' => $fields]);
    }

    public static function donationPayment(array $params): void
    {
        if (!Payfast::isConfigured()) {
            Response::error('PayFast is not configured on the server', 503);
        }

        $donationId = (int) $params['donationId'];
        $donation = Database::queryGet('SELECT * FROM donations WHERE id = ?', [$donationId]);
        if (!$donation) {
            Response::error('Donation not found', 404);
        }
        if ($donation['payment_status'] === 'completed') {
            Response::error('Donation is already completed', 400);
        }

        try {
            $fields = Payfast::buildPaymentPayload([
                'amount' => $donation['amount'],
                'itemName' => "Village Netacad Donation $donationId",
                'paymentId' => "donation-$donationId",
                'email' => $donation['email'] ?: 'donor@villagenetacad.co.za',
                'name' => $donation['donor_name'] ?: 'Donor',
                'returnPath' => "/payment/success?type=donation&id=$donationId",
                'cancelPath' => "/payment/cancel?type=donation&id=$donationId",
            ]);
        } catch (Throwable $e) {
            Response::error($e->getMessage(), 400);
        }

        Response::json(['url' => Payfast::processUrl(), 'fields' => $fields]);
    }

    public static function notify(): void
    {
        http_response_code(200);
        echo 'OK';

        if (function_exists('fastcgi_finish_request')) {
            @fastcgi_finish_request();
        } else {
            if (ob_get_level()) {
                @ob_end_flush();
            }
            @flush();
        }

        try {
            $data = $_POST;
            $mPaymentId = (string) ($data['m_payment_id'] ?? '');
            self::itnLog(
                'hit m_payment_id=' . $mPaymentId
                . ' status=' . ($data['payment_status'] ?? '')
                . ' amount_gross=' . ($data['amount_gross'] ?? '')
                . ' keys=' . implode(',', array_keys($data))
            );

            if (!self::merchantOk($data)) {
                self::itnLog('REJECTED merchant_id mismatch or missing');
                return;
            }

            $localOk = self::localSignatureOk($data);
            $hostOk = Payfast::validateItnWithPayFast($data);

            // Either host VALID or local signature — Afrihost curl to PayFast often fails.
            if (!$localOk && !$hostOk) {
                self::itnLog('REJECTED local_sig=0 host_valid=0 — order left pending');
                return;
            }
            self::itnLog(
                'accepted local_sig=' . ($localOk ? '1' : '0')
                . ' host_valid=' . ($hostOk ? '1' : '0')
            );

            $parsed = self::parsePaymentId($mPaymentId);
            if (!$parsed) {
                self::itnLog('unknown m_payment_id ' . $mPaymentId);
                return;
            }

            $pfStatus = strtoupper((string) ($data['payment_status'] ?? ''));
            if ($pfStatus !== 'COMPLETE') {
                if ($parsed['type'] === 'order') {
                    Database::queryRun(
                        "UPDATE orders SET payment_status = 'failed', updated_at = NOW() WHERE id = ?",
                        [$parsed['id']]
                    );
                } elseif ($parsed['type'] === 'donation') {
                    Database::queryRun(
                        "UPDATE donations SET payment_status = 'failed' WHERE id = ?",
                        [$parsed['id']]
                    );
                } elseif ($parsed['type'] === 'ccna') {
                    Database::queryRun(
                        "UPDATE ccna_enrolments SET payment_status = 'failed', updated_at = NOW() WHERE id = ?",
                        [$parsed['id']]
                    );
                }
                self::itnLog('non-COMPLETE for ' . $mPaymentId);
                return;
            }

            $pfPaymentId = $data['pf_payment_id'] ?? $data['m_payment_id'] ?? '';
            $token = $data['token'] ?? $data['subscription_token'] ?? null;

            if ($parsed['type'] === 'order') {
                $order = Database::queryGet('SELECT * FROM orders WHERE id = ?', [$parsed['id']]);
                if (!$order) {
                    self::itnLog('order not found id=' . $parsed['id']);
                    return;
                }
                if ($order['payment_status'] === 'paid') {
                    self::itnLog('order already paid id=' . $parsed['id']);
                    return;
                }

                $paidAmount = (float) ($data['amount_gross'] ?? $data['amount_net'] ?? 0);
                if (abs($paidAmount - (float) $order['total']) > 0.01) {
                    self::itnLog("amount mismatch $paidAmount vs {$order['total']}");
                    return;
                }

                Database::queryRun('UPDATE orders SET payment_intent_id = ? WHERE id = ?', [$pfPaymentId, $parsed['id']]);
                OrderFulfillment::fulfill($parsed['id']);
                self::itnLog('FULFILLED order id=' . $parsed['id'] . ' referral=' . ($order['referral_code'] ?? ''));
            } elseif ($parsed['type'] === 'donation') {
                $donation = Database::queryGet('SELECT * FROM donations WHERE id = ?', [$parsed['id']]);
                if (!$donation || $donation['payment_status'] === 'completed') {
                    return;
                }

                $paidAmount = (float) ($data['amount_gross'] ?? $data['amount_net'] ?? 0);
                if ($paidAmount > 0 && abs($paidAmount - (float) $donation['amount']) > 0.01) {
                    self::itnLog("donation amount mismatch $paidAmount vs {$donation['amount']}");
                    return;
                }

                Database::queryRun(
                    "UPDATE donations SET payment_status = 'completed', payment_intent_id = ? WHERE id = ?",
                    [$pfPaymentId, $parsed['id']]
                );

                Mailer::send([
                    'to' => Site::email(),
                    'replyTo' => $donation['email'] ?: null,
                    'subject' => 'Donation received: R' . number_format((float) $donation['amount'], 2),
                    'html' => '<p><strong>Donation ID:</strong> ' . $parsed['id'] . '</p>
                        <p><strong>Academy:</strong> ' . htmlspecialchars($donation['academy'] ?? '—') . '</p>
                        <p><strong>Donor:</strong> ' . htmlspecialchars($donation['donor_name']) . '</p>
                        <p><strong>Amount:</strong> R' . number_format((float) $donation['amount'], 2) . '</p>
                        <p><strong>PayFast ref:</strong> ' . htmlspecialchars((string) $pfPaymentId) . '</p>',
                ]);
                self::itnLog('donation completed id=' . $parsed['id']);
            } elseif ($parsed['type'] === 'ccna') {
                $enrolment = Database::queryGet('SELECT * FROM ccna_enrolments WHERE id = ?', [$parsed['id']]);
                if (!$enrolment || $enrolment['payment_status'] === 'active') {
                    return;
                }

                $paidAmount = (float) ($data['amount_gross'] ?? $data['amount_net'] ?? 0);
                if ($paidAmount > 0 && abs($paidAmount - (float) $enrolment['amount']) > 0.01) {
                    self::itnLog("CCNA amount mismatch $paidAmount vs {$enrolment['amount']}");
                    return;
                }

                Database::queryRun(
                    "UPDATE ccna_enrolments
                     SET payment_status = 'active',
                         payment_intent_id = ?,
                         subscription_token = COALESCE(?, subscription_token),
                         updated_at = NOW()
                     WHERE id = ?",
                    [$pfPaymentId, $token ?: null, $parsed['id']]
                );

                Mailer::send([
                    'to' => Site::email(),
                    'replyTo' => $enrolment['email'] ?: null,
                    'subject' => 'CCNA subscription paid: ' . $enrolment['course_title'],
                    'html' => '<p><strong>Enrolment ID:</strong> ' . $parsed['id'] . '</p>
                        <p><strong>Course:</strong> ' . htmlspecialchars($enrolment['course_title']) . '</p>
                        <p><strong>Student:</strong> ' . htmlspecialchars($enrolment['full_name']) . ' (' . htmlspecialchars($enrolment['email']) . ')</p>
                        <p><strong>Amount:</strong> R' . number_format((float) $enrolment['amount'], 2) . '</p>
                        <p><strong>PayFast ref:</strong> ' . htmlspecialchars((string) $pfPaymentId) . '</p>',
                ]);

                Mailer::send([
                    'to' => $enrolment['email'],
                    'subject' => 'Your Village NetAcad CCNA subscription is active',
                    'html' => '<p>Hi ' . htmlspecialchars($enrolment['full_name']) . ',</p>
                        <p>Thank you. Your PayFast subscription for <strong>' . htmlspecialchars($enrolment['course_title']) . '</strong> is active.</p>
                        <p>— Village NetAcad</p>',
                ]);
                self::itnLog('ccna activated id=' . $parsed['id']);
            }
        } catch (Throwable $e) {
            self::itnLog('error: ' . $e->getMessage());
        }
    }
}
