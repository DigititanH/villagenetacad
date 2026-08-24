import 'package:digititan_mobile/shared/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Phase 3 shop URL is Village NetAcad, not Digititan shop', () {
    expect(AppConfig.villageNetAcadShopUrl, 'https://villagenetacad.co.za/shop');
    expect(AppConfig.villageNetAcadShopUrl.contains('shop.digititan'), isFalse);
    expect(AppConfig.digititanStoreUrl, AppConfig.villageNetAcadShopUrl);
  });
}
