/// App-level constants (no secrets here).
class AppConfig {
  /// Official Digititan Store website (same catalogue / PayFast merchant).
  static const digititanStoreUrl = 'https://www.shop.digititan.co.za/';

  /// Same gateway as Digititan Store / website (Phase 2 story; live in Phase 7).
  static const paymentGatewayName = 'PayFast';

  /// Prototype notice shown in Store tab.
  static const storeModeMessage =
      'Browse sample products here. Checkout uses the same PayFast gateway '
      'story as the Digititan Store (full live pay in later phases).';

  static const emailOtpDemo = '123456';
  static const smsOtpDemo = '123456';
  static const paymentOtpDemo = '654321';

  /// Meeting Wave 1: minimum reseller withdrawal (ZAR).
  static const minWithdrawalZar = 100.0;

  /// Locked returns window after delivery.
  static const returnWindowDays = 7;

  static const pinnacleWarrantyNote =
      'Hardware carries Pinnacle warranty as stated on the product. '
      'Keep your proof of purchase. International delivery may take 1–2 months.';

  static const purchaseTermsShort =
      'By buying you accept Digititan / Village NetAcad purchase terms: '
      'international orders may take 1–2 months; returns within '
      '$returnWindowDays days of delivery if unused; warranty via Pinnacle '
      'where applicable. Never pay cash to individuals or ambassadors.';

  static const demoModeLine =
      'Presentation demo · Phase 2 story · sample data';

  /// Deep-link / QR payload for reseller legitimacy check.
  static String resellerVerifyPayload(String code) =>
      'vna://verify/${code.trim().toUpperCase()}';

  /// Grand: withdrawals only on the last calendar day of the month.
  static bool isLastDayOfMonth([DateTime? now]) {
    final d = now ?? DateTime.now();
    final last = DateTime(d.year, d.month + 1, 0).day;
    return d.day == last;
  }

  static DateTime lastDayOfMonth([DateTime? now]) {
    final d = now ?? DateTime.now();
    return DateTime(d.year, d.month + 1, 0);
  }

  static String lastDayLabel([DateTime? now]) {
    final last = lastDayOfMonth(now);
    return '${last.year}-${last.month.toString().padLeft(2, '0')}-${last.day.toString().padLeft(2, '0')}';
  }
}
