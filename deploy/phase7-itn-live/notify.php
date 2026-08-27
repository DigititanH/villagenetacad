<?php
/**
 * Legacy PayFast ITN entry point.
 *
 * Upload to:  public_html/payfast/notify.php
 *
 * DO NOT put this under:
 *   public_html/backend-php/payfast/     (wrong — PayFast never hits that URL)
 *   public_html/village-netacad/...     (stale duplicate)
 *
 * Prefer .env on live API:
 *   PAYFAST_NOTIFY_URL=https://villagenetacad.co.za/api/payfast/notify
 *
 * This file keeps the old dashboard URL working by calling the same
 * controller as POST /api/payfast/notify (signature check + mark paid).
 */
require_once dirname(__DIR__) . '/backend-php/bootstrap.php';

PayfastController::notify();
