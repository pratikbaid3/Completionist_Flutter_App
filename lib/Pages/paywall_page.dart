import 'package:flutter/material.dart';
import 'package:game_trophy_manager/Provider/premium_provider.dart';
import 'package:game_trophy_manager/Utilities/analytics.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// TODO(CMP-3): final copy and triggers come from the PM paywall spec.
class PaywallPage extends StatefulWidget {
  final String source;
  const PaywallPage({required this.source});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  @override
  void initState() {
    super.initState();
    Analytics.logPaywallViewed(source: widget.source);
  }

  Future<void> _done(bool unlocked, String failMsg) async {
    if (!mounted) return;
    if (unlocked) {
      Navigator.of(context).pop(true);
    } else if (failMsg.isNotEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failMsg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final premium = context.watch<PremiumProvider>();
    final packages = [
      premium.offering?.monthly,
      premium.offering?.annual,
    ].whereType<Package>().toList();

    return Scaffold(
      appBar: AppBar(title: const Text('PREMIUM')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Icon(Icons.workspace_premium_rounded,
                size: 64, color: goldenColor),
            const SizedBox(height: 16),
            Text(
              'Unlimited starred & completed trophies',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Free accounts can star $freeCap and complete $freeCap trophies. '
              'Premium removes the limit.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary),
            ),
            const SizedBox(height: 32),
            if (packages.isEmpty)
              Text(
                'Purchases are not available right now. Please try again later.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textMuted),
              ),
            for (final p in packages)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  onPressed: premium.isBusy
                      ? null
                      : () async => _done(await premium.purchase(p), ''),
                  child: Text(_label(p)),
                ),
              ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: premium.isBusy || !premium.isConfigured
                  ? null
                  : () async => _done(
                      await premium.restore(), 'No active Premium found.'),
              child: const Text('Restore purchases'),
            ),
            if (premium.isBusy)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  String _label(Package p) {
    final price = p.storeProduct.priceString;
    return p.packageType == PackageType.annual
        ? 'Annual · $price / year'
        : 'Monthly · $price / month';
  }
}
