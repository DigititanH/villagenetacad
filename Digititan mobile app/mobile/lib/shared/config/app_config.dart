/// App-level constants (no secrets here).
class AppConfig {
  /// Official Digititan Store website (same catalogue / PayFast merchant).
  static const digititanStoreUrl = 'https://www.shop.digititan.co.za/';

  /// Same gateway as Digititan Store / website.
  static const paymentGatewayName = 'PayFast';

  /// Prototype notice shown in Store tab.
  static const storeModeMessage =
      'Shop in-app with PayFast (same gateway as the Digititan Store), '
      'or open the full website catalogue.';

  static const emailOtpDemo = '123456';
  static const smsOtpDemo = '123456';
  static const paymentOtpDemo = '654321';

  /// Meeting feedback: minimum reseller withdrawal (ZAR).
  static const minWithdrawalZar = 100.0;

  static const demoModeLine =
      'Presentation demo · sample data · mobile + website ecosystem';

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
