import 'package:flutter_test/flutter_test.dart';
import 'package:game_trophy_manager/Provider/premium_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  legacyTests();

  test('free tier allows adds below the cap only', () {
    expect(canAddUnderCap(isPremium: false, currentCount: 0), isTrue);
    expect(canAddUnderCap(isPremium: false, currentCount: freeCap - 1), isTrue);
    expect(canAddUnderCap(isPremium: false, currentCount: freeCap), isFalse);
    expect(canAddUnderCap(isPremium: false, currentCount: 40), isFalse);
  });

  test('premium is never capped', () {
    expect(canAddUnderCap(isPremium: true, currentCount: 999), isTrue);
  });
}

// Legacy grace (spec option B): granted once, only to existing installs.
Future<DateTime?> _grace(bool existing, DateTime now, List<int> granted) async {
  final prefs = await SharedPreferences.getInstance();
  return resolveLegacyGrace(prefs,
      existingInstall: existing, now: now, onGranted: () => granted.add(1));
}

void legacyTests() {
  final t0 = DateTime(2026, 12, 1);

  test('existing install gets grace once', () async {
    SharedPreferences.setMockInitialValues({});
    final granted = <int>[];
    final until = await _grace(true, t0, granted);
    expect(until, t0.add(const Duration(days: legacyGraceDays)));
    // Later launches keep the same end and never re-grant.
    expect(await _grace(true, t0.add(const Duration(days: 50)), granted), until);
    expect(granted.length, 1);
  });

  test('new install gets no grace, even on later launches', () async {
    SharedPreferences.setMockInitialValues({});
    final granted = <int>[];
    expect(await _grace(false, t0, granted), isNull);
    expect(await _grace(true, t0, granted), isNull);
    expect(granted, isEmpty);
  });
}
