<?php
/**
 * Legacy PayFast ITN entry point.
 *
 * Upload to: public_html/payfast/notify.php
 * (NOT village-netacad/… — that tree is a stale duplicate)
 *
 * Prefer setting .env:
 *   PAYFAST_NOTIFY_URL=https://villagenetacad.co.za/api/payfast/notify
 * This file keeps old PayFast dashboard / bookmarks working by calling
 * the same controller as POST /api/payfast/notify.
 */
require_once dirname(__DIR__) . '/backend-php/bootstrap.php';

PayfastController::notify();
