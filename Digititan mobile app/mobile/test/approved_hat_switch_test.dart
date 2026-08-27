import 'package:digititan_mobile/infrastructure/dummy/demo_hub.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Approved hats resolve from DemoHub by email', () {
    final hub = DemoHub.instance;
    expect(hub.isApprovedReseller('reseller@demo.com'), isTrue);
    expect(hub.isApprovedAmbassador('lerato.ambassador@example.com'), isTrue);
    expect(hub.isApprovedReseller('customer@demo.com'), isFalse);
    expect(hub.isApprovedAmbassador('customer@demo.com'), isFalse);
  });
}
