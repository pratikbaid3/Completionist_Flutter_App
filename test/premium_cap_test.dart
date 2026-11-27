import 'package:flutter_test/flutter_test.dart';
import 'package:game_trophy_manager/Provider/premium_provider.dart';

void main() {
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
