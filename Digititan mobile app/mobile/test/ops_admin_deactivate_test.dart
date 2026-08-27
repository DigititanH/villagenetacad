import 'package:digititan_mobile/domain/entities/reseller.dart';
import 'package:digititan_mobile/infrastructure/dummy/demo_hub.dart';
import 'package:digititan_mobile/infrastructure/dummy/dummy_admin_repository.dart';
import 'package:digititan_mobile/infrastructure/dummy/dummy_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DummyAdminRepository admin;
  late DummyAuthRepository auth;
  late DemoHub hub;

  setUp(() {
    hub = DemoHub.instance;
    // Clear lockouts from prior tests without wiping seed data.
    hub.deactivatedEmails.clear();
    for (final c in hub.codesByValue.values) {
      c.active = true;
    }
    final reseller = hub.resellerProfiles['reseller@demo.com'];
    if (reseller != null && reseller.status == 'deactivated') {
      hub.resellerProfiles['reseller@demo.com'] =
          reseller.copyWith(status: 'approved');
    }
    for (final a in hub.ambassadorApplications) {
      if (a.id == 'amb-1' && a.status != 'under_review') {
        a.status = 'under_review';
      }
      if (a.id == 'amb-2') {
        a.status = 'approved';
      }
    }
    admin = DummyAdminRepository();
    auth = DummyAuthRepository();
  });

  test('Ops can list ambassadors and approve under_review', () async {
    final all = await admin.getAmbassadorApplications();
    expect(all.length, greaterThanOrEqualTo(2));

    final pending = await admin.getAmbassadorApplications(status: 'under_review');
    expect(pending.any((a) => a.id == 'amb-1'), isTrue);

    await admin.approveAmbassador('amb-1');
    final approved = hub.ambassadorApplications.firstWhere((a) => a.id == 'amb-1');
    expect(approved.status, 'approved');
  });

  test('Deactivate ambassador locks login until unlock', () async {
    await admin.deactivateAmbassador('amb-2');
    final a = hub.ambassadorApplications.firstWhere((x) => x.id == 'amb-2');
    expect(a.status, 'deactivated');
    expect(hub.isLoginLocked('lerato.ambassador@example.com'), isTrue);

    await expectLater(
      auth.signInWithEmail(
        email: 'lerato.ambassador@example.com',
        password: 'demo123',
      ),
      throwsA(
        predicate(
          (e) =>
              e is Exception &&
              e.toString().contains('deactivated') &&
              e.toString().contains('Digititan'),
        ),
      ),
    );

    await admin.reactivateAmbassador('amb-2');
    expect(hub.isLoginLocked('lerato.ambassador@example.com'), isFalse);
    final user = await auth.signInWithEmail(
      email: 'lerato.ambassador@example.com',
      password: 'demo123',
    );
    expect(user.email, 'lerato.ambassador@example.com');
  });

  test('Deactivate reseller locks login and disables code', () async {
    final before = hub.findCode('VNA-B-LERATO');
    expect(before, isNotNull);

    await admin.deactivateReseller('reseller@demo.com');
    final profile = hub.resellerProfiles['reseller@demo.com']!;
    expect(profile.status, 'deactivated');
    expect(hub.findCode('VNA-B-LERATO'), isNull);
    expect(hub.isLoginLocked('reseller@demo.com'), isTrue);

    await expectLater(
      auth.signInWithEmail(email: 'reseller@demo.com', password: 'demo123'),
      throwsA(
        predicate((e) => e is Exception && e.toString().contains('deactivated')),
      ),
    );

    await admin.reactivateReseller('reseller@demo.com');
    expect(hub.resellerProfiles['reseller@demo.com']!.status, 'approved');
    expect(hub.findCode('VNA-B-LERATO'), isNotNull);
    final user = await auth.signInWithEmail(
      email: 'reseller@demo.com',
      password: 'demo123',
    );
    expect(user.email, 'reseller@demo.com');
  });

  test('Admin stats include pending ambassadors', () async {
    hub.ambassadorApplications.firstWhere((a) => a.id == 'amb-1').status =
        'under_review';
    final stats = await admin.getStats();
    expect(stats.pendingAmbassadors, greaterThanOrEqualTo(1));
  });

  test('getResellerProfiles returns all profiles for Ops list', () async {
    final profiles = await admin.getResellerProfiles();
    expect(profiles.any((p) => p.email == 'reseller@demo.com'), isTrue);
    expect(profiles.first, isA<ResellerProfile>());
  });
}
