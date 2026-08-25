/// App-level constants (no secrets here).
class AppConfig {
  /// Village NetAcad shop (Phase 3 — not shop.digititan.co.za).
  static const villageNetAcadShopUrl = 'https://villagenetacad.co.za/shop';

  /// @Deprecated Prefer [villageNetAcadShopUrl]. Kept so older call sites compile.
  static const digititanStoreUrl = villageNetAcadShopUrl;

  /// Phase 4 — shared accounts API (same as website).
  /// Pass via `--dart-define=API_BASE_URL=https://villagenetacad.co.za`
  /// or local e.g. `http://10.0.2.2:5000` (Android emulator → host).
  /// Empty = keep dummy auth for decks.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// True when [apiBaseUrl] is set — use live `/api` (auth + store cart).
  static bool get useLiveApi => apiBaseUrl.trim().isNotEmpty;

  /// Website PayFast checkout (Phase 5+). Opens `/checkout` so after login the
  /// customer lands on checkout (not home). Unauthenticated users hit
  /// ProtectedRoute → `/login?next=/checkout` → checkout.
  static String get villageNetAcadCartUrl {
    final base = apiBaseUrl.trim().isNotEmpty
        ? apiBaseUrl.replaceAll(RegExp(r'/$'), '')
        : 'https://villagenetacad.co.za';
    return '$base/checkout';
  }

  /// Same PayFast gateway story as the Village NetAcad website (live in Phase 7).
  static const paymentGatewayName = 'PayFast';

  /// Prototype notice shown in Store tab (dummy).
  static const storeModeMessage =
      'Browse sample products here. Full shop is the Village NetAcad website '
      '(same PayFast gateway story — live pay in later phases).';

  /// Live Phase 5 notice (when API has products).
  static const storeLiveCartMessage =
      'Live catalogue + shared cart with the website. '
      'Checkout opens villagenetacad.co.za for PayFast. '
      'Orders appear under My orders after payment.';

  /// Shown when live `/api/products` returns empty (production today).
  static const storeLiveEmptyCatalogueMessage =
      'Live shop DB has no products yet — showing samples for UAT. '
      'You can add to a walkthrough cart and tap Complete on website '
      'to open villagenetacad.co.za/cart (real shared cart starts when '
      'Admin adds products).';

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
      'By buying you accept Village NetAcad purchase terms: '
      'international orders may take 1–2 months; returns within '
      '$returnWindowDays days of delivery if unused; warranty via Pinnacle '
      'where applicable. Never pay cash to individuals or ambassadors.';

  static String get demoModeLine => useLiveApi
      ? 'Phase 6 · live API · $apiBaseUrl'
      : 'Presentation demo · Phase 3/6 · dummy auth (set API_BASE_URL for live)';

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
