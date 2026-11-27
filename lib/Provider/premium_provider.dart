import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:game_trophy_manager/Utilities/analytics.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Free tier: at most this many starred and this many completed trophies.
const int freeCap = 5;
const String premiumEntitlement = 'premium';

/// Legacy grace length (spec option B). CMP-2 may change it to 14.
const int legacyGraceDays = 90;
const int _reminderDaysLeft = 7;

/// QA only: shift "now" by N days in debug/profile builds
/// (--dart-define=DEBUG_DAY_OFFSET=83). Ignored in release builds.
const int _debugDayOffset = int.fromEnvironment('DEBUG_DAY_OFFSET');
DateTime premiumNow() => kReleaseMode
    ? DateTime.now()
    : DateTime.now().add(const Duration(days: _debugDayOffset));

/// Pure cap rule, kept separate so it is testable without RevenueCat.
bool canAddUnderCap({required bool isPremium, required int currentCount}) =>
    isPremium || currentCount < freeCap;

/// Legacy grace state machine over prefs, pure enough to unit test.
/// Returns the grace end, granting it once if this was an existing install.
Future<DateTime?> resolveLegacyGrace(
  SharedPreferences prefs, {
  required bool existingInstall,
  required DateTime now,
  required void Function() onGranted,
}) async {
  if (!prefs.containsKey('legacy_checked')) {
    await prefs.setBool('legacy_checked', true);
    if (existingInstall) {
      final until = now.add(const Duration(days: legacyGraceDays));
      await prefs.setString('legacy_grace_until', until.toIso8601String());
      await prefs.setBool('legacy_notice_pending', true);
      onGranted();
    }
  }
  final raw = prefs.getString('legacy_grace_until');
  return raw == null ? null : DateTime.tryParse(raw);
}

/// RevenueCat public SDK keys, passed at build time:
/// --dart-define=RC_ANDROID_KEY=goog_... --dart-define=RC_IOS_KEY=appl_...
/// Empty (placeholder) => store unavailable; free tier + legacy grace still work.
/// App user ids are anonymous (no logIn); restore goes through the store account.
const _androidKey = String.fromEnvironment('RC_ANDROID_KEY');
const _iosKey = String.fromEnvironment('RC_IOS_KEY');

enum LegacyPrompt { none, notice, reminder }

class PremiumProvider extends ChangeNotifier {
  final bool existingInstall;
  PremiumProvider({required this.existingInstall}) {
    _init();
  }

  bool hasEntitlement = false;
  bool isTrial = false;
  String? managementUrl;
  DateTime? graceUntil;
  bool isConfigured = false;
  bool isBusy = false;
  bool offeringsFailed = false;
  Offering? offering;
  final Map<String, bool> _trialEligible = {};

  /// Kill switch (AC12). TODO: wire to remote config `paywall_enabled` once
  /// firebase_remote_config is approved; shipped default is true.
  bool paywallEnabled = true;

  bool get inGrace =>
      graceUntil != null && premiumNow().isBefore(graceUntil!);
  bool get isPremium => hasEntitlement || inGrace;
  String get tier => hasEntitlement
      ? (isTrial ? 'trial' : 'premium')
      : (inGrace ? 'legacy_grace' : 'free');

  bool canAdd(int currentCount) =>
      canAddUnderCap(isPremium: isPremium, currentCount: currentCount);

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      graceUntil = await resolveLegacyGrace(prefs,
          existingInstall: existingInstall,
          now: premiumNow(),
          onGranted: Analytics.logLegacyGraceStarted);
      if (graceUntil != null &&
          !inGrace &&
          !(prefs.getBool('legacy_grace_ended_logged') ?? false)) {
        await prefs.setBool('legacy_grace_ended_logged', true);
        Analytics.logLegacyGraceEnded();
      }
      _publishTier();
      notifyListeners();
    } catch (_) {}

    final key = Platform.isIOS ? _iosKey : _androidKey;
    if (key.isEmpty) return;
    try {
      await Purchases.configure(PurchasesConfiguration(key));
      isConfigured = true;
      Purchases.addCustomerInfoUpdateListener(_apply);
      _apply(await Purchases.getCustomerInfo());
    } catch (_) {}
    await loadOfferings();
  }

  Future<void> loadOfferings() async {
    if (!isConfigured) {
      offeringsFailed = true;
      notifyListeners();
      return;
    }
    offeringsFailed = false;
    notifyListeners();
    try {
      offering = (await Purchases.getOfferings()).current;
      offeringsFailed = offering == null;
      if (Platform.isIOS && offering != null) {
        final ids = offering!.availablePackages
            .map((p) => p.storeProduct.identifier)
            .toList();
        final elig =
            await Purchases.checkTrialOrIntroductoryPriceEligibility(ids);
        elig.forEach((id, e) => _trialEligible[id] =
            e.status == IntroEligibilityStatus.introEligibilityStatusEligible);
      }
    } catch (_) {
      offeringsFailed = true;
    }
    notifyListeners();
  }

  /// Free-trial length in days if the user can start one, else null.
  /// Play only returns offers the user is eligible for; iOS needs the check.
  int? trialDays(StoreProduct p) {
    if (Platform.isIOS) {
      final intro = p.introductoryPrice;
      if (intro == null || intro.price != 0 || _trialEligible[p.identifier] != true) {
        return null;
      }
      return _days(intro.periodUnit, intro.periodNumberOfUnits);
    }
    final period = p.defaultOption?.freePhase?.billingPeriod;
    return period == null ? null : _days(period.unit, period.value);
  }

  static int _days(PeriodUnit unit, int n) {
    if (unit == PeriodUnit.week) return n * 7;
    if (unit == PeriodUnit.month) return n * 30;
    if (unit == PeriodUnit.year) return n * 365;
    return n;
  }

  void _apply(CustomerInfo info) {
    final ent = info.entitlements.active[premiumEntitlement];
    hasEntitlement = ent != null;
    isTrial = ent?.periodType == PeriodType.trial;
    managementUrl = info.managementURL;
    _publishTier();
    notifyListeners();
  }

  void _publishTier() => Analytics.setTier(tier);

  /// Returns true when the purchase unlocked premium.
  Future<bool> purchase(Package package) async {
    final product = package.storeProduct;
    final plan = planName(package);
    final trial = trialDays(product) != null;
    final country = await _country();
    Analytics.logPurchaseStarted(plan: plan, trial: trial);
    _setBusy(true);
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      _apply(result.customerInfo);
      if (isTrial) Analytics.logTrialStarted(plan: plan);
      Analytics.logPurchaseSuccess(
        plan: plan,
        price: product.price,
        currency: product.currencyCode,
        country: country,
        trial: isTrial,
      );
      return hasEntitlement;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      Analytics.logPurchaseFailed(
        plan: plan,
        errorCode: code.toString().split('.').last,
        userCancelled: code == PurchasesErrorCode.purchaseCancelledError,
      );
      if (code == PurchasesErrorCode.purchaseCancelledError) return false;
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  /// 'restored' | 'none' | 'error'
  Future<String> restore() async {
    Analytics.logRestoreTapped();
    var result = 'error';
    if (isConfigured) {
      _setBusy(true);
      try {
        _apply(await Purchases.restorePurchases());
        result = hasEntitlement ? 'restored' : 'none';
      } catch (_) {
      } finally {
        _setBusy(false);
      }
    }
    Analytics.logRestoreResult(result: result);
    return result;
  }

  /// Which one-time legacy prompt to show now, if any; marks it as shown.
  Future<LegacyPrompt> takeLegacyPrompt() async {
    if (!inGrace) return LegacyPrompt.none;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('legacy_notice_pending') ?? false) {
      await prefs.setBool('legacy_notice_pending', false);
      return LegacyPrompt.notice;
    }
    final daysLeft = graceUntil!.difference(premiumNow()).inDays;
    if (daysLeft <= _reminderDaysLeft &&
        !(prefs.getBool('legacy_reminder_shown') ?? false)) {
      await prefs.setBool('legacy_reminder_shown', true);
      return LegacyPrompt.reminder;
    }
    return LegacyPrompt.none;
  }

  static String planName(Package p) =>
      p.packageType == PackageType.annual ? 'annual' : 'monthly';

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
