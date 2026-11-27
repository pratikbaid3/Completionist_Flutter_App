import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_trophy_manager/Provider/premium_provider.dart';
import 'package:game_trophy_manager/Router/router_constant.dart';
import 'package:game_trophy_manager/Utilities/analytics.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO(CMP-4): real URLs pending from god; both stores require them.
const _termsUrl = 'https://example.com/terms';
const _privacyUrl = 'https://example.com/privacy';

/// Full-screen paywall (hive paywall-v1-spec). Pops `true` when Premium unlocked.
class PaywallPage extends StatefulWidget {
  final String source;
  const PaywallPage({required this.source});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  Package? _selected;
  String? _error;
  bool _purchased = false;

  @override
  void initState() {
    super.initState();
    Analytics.logPaywallViewed(source: widget.source);
  }

  @override
  void dispose() {
    Analytics.logPaywallClosed(source: widget.source, purchased: _purchased);
    super.dispose();
  }

  void _close() => Navigator.of(context).pop(_purchased);

  void _success() {
    _purchased = true;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("You're Premium 🎉")));
    _close();
  }

  Future<void> _buy(PremiumProvider premium, Package p) async {
    setState(() => _error = null);
    try {
      if (await premium.purchase(p) && mounted) _success();
    } on PlatformException catch (e) {
      if (mounted) setState(() => _error = e.message ?? 'Purchase failed.');
    }
  }

  Future<void> _restore(PremiumProvider premium) async {
    final r = await premium.restore();
    if (!mounted) return;
    if (r == 'restored') return _success();
    setState(() => _error =
        r == 'none' ? 'No purchases found.' : "Couldn't restore. Try again.");
  }

  @override
  Widget build(BuildContext context) {
    final premium = context.watch<PremiumProvider>();
    final annual = premium.offering?.annual;
    final monthly = premium.offering?.monthly;
    _selected ??= annual ?? monthly;
    final store = Platform.isIOS ? 'App Store' : 'Google Play';

    return PopScope(
      canPop: !premium.isBusy,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              tooltip: 'Close',
              icon: const Icon(Icons.close_rounded),
              onPressed: premium.isBusy ? null : _close,
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            children: [
              Icon(Icons.workspace_premium_rounded,
                  size: 56, color: goldenColor),
              const SizedBox(height: 12),
              Text('Track every trophy.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                'Free lets you star and complete $freeCap trophies. '
                'Premium removes the limit.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textSecondary),
              ),
              const SizedBox(height: 20),
              for (final b in const [
                'Unlimited starred trophies',
                'Unlimited completed trophies',
                'Support new guides and PS5 coverage',
              ])
                ListTile(
                  dense: true,
                  leading: Icon(Icons.check_rounded, color: neonGreen),
                  title: Text(b),
                ),
              const SizedBox(height: 16),
              if (premium.offering == null && !premium.offeringsFailed)
                const Center(child: CircularProgressIndicator())
              else if (premium.offering == null)
                Column(children: [
                  Text("Couldn't load plans.",
                      style: TextStyle(color: textMuted)),
                  TextButton(
                      onPressed: premium.loadOfferings,
                      child: const Text('Try again')),
                ])
              else ...[
                if (annual != null)
                  _planCard(premium, annual, monthly, 'Best value'),
                if (monthly != null) _planCard(premium, monthly, null, null),
                const SizedBox(height: 12),
                if (_selected != null) ..._cta(premium, _selected!, store),
              ],
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: neonPink)),
                ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  TextButton(
                    onPressed: premium.isBusy ? null : () => _restore(premium),
                    child: const Text('Restore purchases'),
                  ),
                  TextButton(
                    onPressed: () => launchUrl(Uri.parse(_termsUrl)),
                    child: const Text('Terms'),
                  ),
                  TextButton(
                    onPressed: () => launchUrl(Uri.parse(_privacyUrl)),
                    child: const Text('Privacy'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _cta(PremiumProvider premium, Package p, String store) {
    final product = p.storeProduct;
    final per = p.packageType == PackageType.annual ? 'year' : 'month';
    final trial = premium.trialDays(product);
    final price = '${product.priceString}/$per';
    final disclosure = trial != null
        ? 'Free for $trial days, then $price. Auto-renews until cancelled. '
            'Cancel anytime in your $store settings at least 24 hours before the trial ends.'
        : '$price. Auto-renews until cancelled. Cancel anytime in your $store settings.';
    return [
      ElevatedButton(
        onPressed: premium.isBusy ? null : () => _buy(premium, p),
        child: premium.isBusy
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2))
            : Text(trial != null ? 'Start $trial-day free trial' : 'Subscribe'),
      ),
      const SizedBox(height: 8),
      Text(disclosure,
          textAlign: TextAlign.center,
          style: TextStyle(color: textMuted, fontSize: 12)),
    ];
  }

  Widget _planCard(
      PremiumProvider premium, Package p, Package? monthly, String? badge) {
    final product = p.storeProduct;
    final selected = identical(_selected, p);
    String label;
    if (p.packageType == PackageType.annual) {
      label = '${product.priceString}/year';
      final perMonth = product.pricePerMonthString;
      if (perMonth != null) label += ' · just $perMonth/month';
      final m = monthly?.storeProduct.price;
      if (m != null && m > 0) {
        final save = ((1 - product.price / (m * 12)) * 100).round();
        if (save > 0) label += ' · Save $save%';
      }
    } else {
      label = '${product.priceString}/month';
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: premium.isBusy
            ? null
            : () {
                Analytics.logPlanSelected(plan: PremiumProvider.planName(p));
                setState(() => _selected = p);
              },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? primaryAccentColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? primaryAccentColor : textMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        p.packageType == PackageType.annual
                            ? 'Annual'
                            : 'Monthly',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(label, style: TextStyle(color: textSecondary)),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: goldenColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(badge,
                      style: TextStyle(color: goldenColor, fontSize: 12)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shared entry points (cap gate, counter, settings, legacy prompts).
/// Returns true if Premium is active after the paywall closes.
Future<bool> openPaywall(BuildContext context, String source) async {
  final premium = context.read<PremiumProvider>();
  if (!premium.paywallEnabled) return premium.isPremium;
  final r = await Navigator.of(context).pushNamed(paywallRoute, arguments: source);
  return r == true || premium.isPremium;
}

/// Free-tier gate for adding a trophy. [type] = 'star' | 'complete'.
/// At the cap: logs cap_hit and opens the paywall; true if the add may proceed.
Future<bool> premiumGate(BuildContext context, String type, int count) async {
  final premium = context.read<PremiumProvider>();
  if (premium.canAdd(count)) return true;
  Analytics.logCapHit(type: type, count: count);
  if (!premium.paywallEnabled) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Free accounts can $type up to $freeCap trophies.')));
    return false;
  }
  return openPaywall(context, 'cap_$type');
}

/// Settings entry: paywall for free users, status sheet for subscribers.
Future<void> openPremiumSettings(BuildContext context) async {
  final premium = context.read<PremiumProvider>();
  if (!premium.hasEntitlement) {
    await openPaywall(context, 'settings');
    return;
  }
  final url = premium.managementUrl ??
      (Platform.isIOS
          ? 'https://apps.apple.com/account/subscriptions'
          : 'https://play.google.com/store/account/subscriptions');
  await showModalBottomSheet(
    context: context,
    builder: (_) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(
          leading: Icon(Icons.workspace_premium_rounded, color: goldenColor),
          title: const Text('Premium active'),
        ),
        ListTile(
          leading: const Icon(Icons.open_in_new_rounded),
          title: const Text('Manage subscription'),
          onTap: () => launchUrl(Uri.parse(url),
              mode: LaunchMode.externalApplication),
        ),
      ]),
    ),
  );
}

/// One-time legacy grace notice / day-83 reminder (call after first frame).
Future<void> maybeShowLegacyPrompt(BuildContext context) async {
  final premium = context.read<PremiumProvider>();
  final prompt = await premium.takeLegacyPrompt();
  if (prompt == LegacyPrompt.none || !context.mounted) return;
  final notice = prompt == LegacyPrompt.notice;
  final seePremium = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      content: Text(notice
          ? "Thanks for being an early Completionist. Premium is now available — "
              "you've got $legacyGraceDays days of it free, no card needed."
          : 'Your free Premium ends in 7 days.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Got it')),
        TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('See Premium')),
      ],
    ),
  );
  if (seePremium == true && context.mounted) {
    await openPaywall(context, notice ? 'legacy_notice' : 'legacy_reminder');
  }
}
