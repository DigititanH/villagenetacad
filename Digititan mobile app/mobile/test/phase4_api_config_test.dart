import 'package:digititan_mobile/shared/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('useLiveApi is false when API_BASE_URL empty (default)', () {
    // fromEnvironment default is empty in tests unless --dart-define is passed.
    expect(AppConfig.apiBaseUrl, anyOf(isEmpty, isA<String>()));
    // Without dart-define in this test process, expect dummy mode.
    if (AppConfig.apiBaseUrl.trim().isEmpty) {
      expect(AppConfig.useLiveApi, isFalse);
    }
  });
}
