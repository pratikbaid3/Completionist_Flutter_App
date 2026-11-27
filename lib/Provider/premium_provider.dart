import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:game_trophy_manager/Utilities/analytics.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Free tier: at most this many starred and this many completed trophies.
const int freeCap = 5;
const String premiumEntitlement = 'premium';

/// Pure cap rule, kept separate so it is testable without RevenueCat.
bool canAddUnderCap({required bool isPremium, required int currentCount}) =>
    isPremium || currentCount < freeCap;

/// RevenueCat public SDK keys, passed at build time:
/// --dart-define=RC_ANDROID_KEY=goog_... --dart-define=RC_IOS_KEY=appl_...
/// Empty (placeholder) => store is unavailable and everyone is on the free tier.
const _androidKey = String.fromEnvironment('RC_ANDROID_KEY');
const _iosKey = String.fromEnvironment('RC_IOS_KEY');

class PremiumProvider extends ChangeNotifier {
  bool isPremium = false;
  bool isConfigured = false;
  bool isBusy = false;
  Offering? offering;

  PremiumProvider() {
    _init();
  }

  bool canAdd(int currentCount) =>
      canAddUnderCap(isPremium: isPremium, currentCount: currentCount);

  Future<void> _init() async {
    final key = Platform.isIOS ? _iosKey : _androidKey;
    if (key.isEmpty) return;
    try {
      await Purchases.configure(PurchasesConfiguration(key));
      isConfigured = true;
      Purchases.addCustomerInfoUpdateListener(_apply);
      _apply(await Purchases.getCustomerInfo());
      offering = (await Purchases.getOfferings()).current;
      notifyListeners();
    } catch (_) {}
  }

  void _apply(CustomerInfo info) {
    final active = info.entitlements.active.containsKey(premiumEntitlement);
    if (active == isPremium) return;
    isPremium = active;
    notifyListeners();
  }

  /// Returns true when the purchase unlocked premium.
  Future<bool> purchase(Package package) async {
    final product = package.storeProduct;
    final plan = product.identifier;
    final price = product.priceString;
    final country = await _country();
    _setBusy(true);
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      _apply(result.customerInfo);
      final ent = result.customerInfo.entitlements.active[premiumEntitlement];
      if (ent?.periodType == PeriodType.trial) {
        Analytics.logTrialStarted(plan: plan);
      }
      Analytics.logPurchaseSuccess(plan: plan, price: price, country: country);
      return isPremium;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      Analytics.logPurchaseFail(
        plan: plan,
        price: price,
        country: country,
        reason: code == PurchasesErrorCode.purchaseCancelledError
            ? 'cancelled'
            : e.code,
      );
      return false;
    } finally {
      _setBusy(false);
    }
  }

  /// Returns true when an active premium entitlement was restored.
  Future<bool> restore() async {
    if (!isConfigured) return false;
    _setBusy(true);
    try {
      _apply(await Purchases.restorePurchases());
      return isPremium;
    } catch (_) {
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<String> _country() async {
    try {
      return (await Purchases.storefront)?.countryCode ?? 'unknown';
    } catch (_) {
      return 'unknown';
    }
  }

  void _setBusy(bool v) {
    isBusy = v;
    notifyListeners();
  }
}
