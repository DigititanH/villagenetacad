/// App-level constants (no secrets here).
class AppConfig {
  /// Official Digititan Store website for full shopping.
  static const digititanStoreUrl = 'https://www.shop.digititan.co.za/';

  /// Prototype notice shown in Store tab.
  static const storeModeMessage =
      'Browse sample products here. Full shopping is on the Digititan Store website.';

  static const emailOtpDemo = '123456';
  static const paymentOtpDemo = '654321';

  /// Meeting Wave 1: minimum reseller withdrawal (ZAR).
  static const minWithdrawalZar = 100.0;

  static const demoModeLine =
      'Presentation demo · sample data · mobile + website ecosystem';

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
