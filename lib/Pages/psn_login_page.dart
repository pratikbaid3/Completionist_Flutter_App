import 'dart:ui';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_trophy_manager/Provider/psn_sync_provider.dart';
import 'package:game_trophy_manager/Widgets/aurora_background.dart';
import 'package:game_trophy_manager/Utilities/api.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PsnLoginPage extends StatefulWidget {
  const PsnLoginPage({Key? key}) : super(key: key);

  @override
  State<PsnLoginPage> createState() => _PsnLoginPageState();
}

class _PsnLoginPageState extends State<PsnLoginPage>
    with WidgetsBindingObserver {
  static const String _demoToken = 'completionist-demo-psn';
  final TextEditingController _tokenController = TextEditingController();

  String _status = 'Open login, then import your token.';
  bool _isCheckingClipboard = false;

  bool get _hasDetectedToken =>
      (_extractNpsso(_tokenController.text.trim()) ?? '').isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pullTokenFromClipboard(showFeedback: false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tokenController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _pullTokenFromClipboard(showFeedback: false);
    }
  }

  Future<void> _openExternal(String url) async {
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _pullTokenFromClipboard({required bool showFeedback}) async {
    if (_isCheckingClipboard) return;
    _isCheckingClipboard = true;
    try {
      final clipboard = await Clipboard.getData('text/plain');
      final raw = clipboard?.text?.trim() ?? '';
      final token = _extractNpsso(raw);
      if (!mounted) return;

      if (token != null && token.isNotEmpty) {
        _tokenController.text = token;
        setState(() {
          _status =
              'PSN session token detected from clipboard. Continue below.';
        });
        if (showFeedback) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Detected NPSSO from clipboard.')),
          );
        }
      } else if (showFeedback) {
        setState(() {
          _status =
              'No valid NPSSO was found on the clipboard yet. Copy the response from the browser first.';
        });
      }
    } finally {
      _isCheckingClipboard = false;
    }
  }

  String? _extractNpsso(String raw) {
    if (raw.isEmpty) return null;
    if (raw.trim() == _demoToken) return _demoToken;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map && decoded['npsso'] != null) {
        return decoded['npsso'].toString().trim();
      }
    } catch (_) {}

    final jsonMatch = RegExp(r'"npsso"\s*:\s*"([^"]+)"', caseSensitive: false)
        .firstMatch(raw);
    if (jsonMatch != null) {
      return jsonMatch.group(1)?.trim();
    }

    final tokenMatch =
        RegExp(r'([A-Za-z0-9\-_]{40,})', caseSensitive: false).firstMatch(raw);
    return tokenMatch?.group(1)?.trim();
  }

  void _complete() {
    final token = _extractNpsso(_tokenController.text.trim());
    if (token == null || token.isEmpty) {
      setState(() {
        _status =
            'No valid NPSSO token found yet. Open the NPSSO page in your browser, copy the response, then return here.';
      });
      return;
    }
    Navigator.of(context).pop(token);
  }

  void _connectDemoData() {
    Navigator.of(context).pop(_demoToken);
  }

  Future<void> _showPsnInfoSheet(BuildContext context, bool isConnected) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 14, 20, 22),
                decoration: BoxDecoration(
                  color: secondaryColor.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: textMuted.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryAccentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.info_outline_rounded,
                            color: primaryAccentColor,
                            size: 18,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'PSN Sync Info',
                            style: GoogleFonts.orbitron(
                              color: textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14),
                    Text(
                      isConnected
                          ? 'Your account is linked. Use refresh to update synced games and trophy completion.'
                          : 'Connect your PlayStation account to import owned games and trophy completion.',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 14),
                    _InfoRow(
                      icon: Icons.lock_outline_rounded,
                      title: 'On-device storage',
                      description:
                          'Session token and synced snapshot stay on this device.',
                    ),
                    SizedBox(height: 10),
                    _InfoRow(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Guide matching',
                      description:
                          'Completionist maps synced titles to your existing guides where possible.',
                    ),
                    SizedBox(height: 10),
                    _InfoRow(
                      icon: Icons.refresh_rounded,
                      title: 'Refresh support',
                      description:
                          'You can refresh manually anytime from the app bar account menu.',
                    ),
                    SizedBox(height: 14),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepCard({
    required String step,
    required String title,
    required String description,
    required String actionLabel,
    required VoidCallback onPressed,
    required IconData icon,
    required Color accent,
  }) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: glassDecoration(borderRadius: 16, opacity: 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: accent.withValues(alpha: 0.2)),
                ),
                child: Text(
                  step,
                  style: GoogleFonts.inter(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    color: textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accent.withValues(alpha: 0.2)),
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              color: textSecondary,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: textPrimary,
                backgroundColor: Colors.white.withValues(alpha: 0.04),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(icon, size: 18),
              label: Text(
                actionLabel,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final psnProvider = Provider.of<PsnSyncProvider>(context, listen: false);
    final isConnected = psnProvider.isConnected && psnProvider.profile != null;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: Text(
          'Connect PSN',
          style: GoogleFonts.orbitron(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showPsnInfoSheet(context, isConnected),
            icon: Icon(Icons.info_outline_rounded),
            tooltip: 'PSN Info',
          ),
        ],
      ),
      body: AuroraBackground(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: glassDecoration(borderRadius: 14, opacity: 0.06),
                child: Row(
                  children: [
                    Icon(
                      _hasDetectedToken
                          ? Icons.check_circle_rounded
                          : Icons.info_outline_rounded,
                      size: 16,
                      color: _hasDetectedToken ? neonGreen : textSecondary,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _status,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    _InlineStatusPill(
                      label: _hasDetectedToken ? 'Ready' : 'Waiting',
                      color: _hasDetectedToken ? neonGreen : textMuted,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              _buildStepCard(
                step: 'Step 1',
                title: 'Sign in on PlayStation',
                description:
                    'Open PlayStation in your browser and sign in to your account.',
                actionLabel: 'Open Login',
                onPressed: () => _openExternal(psnLoginUrl),
                icon: Icons.open_in_browser_rounded,
                accent: primaryAccentColor,
              ),
              SizedBox(height: 12),
              _buildStepCard(
                step: 'Step 2',
                title: 'Open the NPSSO page',
                description:
                    'Use the same browser session. You should see JSON containing the NPSSO token.',
                actionLabel: 'Open NPSSO Page',
                onPressed: () => _openExternal(psnSsoCookieUrl),
                icon: Icons.security_rounded,
                accent: secondaryAccentColor,
              ),
              SizedBox(height: 12),
              _buildStepCard(
                step: 'Step 3',
                title: 'Import from clipboard',
                description:
                    'Copy the JSON/token in browser, then import it here to auto-fill the field.',
                actionLabel: 'Import From Clipboard',
                onPressed: () => _pullTokenFromClipboard(showFeedback: true),
                icon: Icons.content_paste_go_rounded,
                accent: neonGreen,
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(14),
                decoration: glassDecoration(borderRadius: 16, opacity: 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.vpn_key_rounded,
                            size: 16, color: textSecondary),
                        SizedBox(width: 8),
                        Text(
                          'NPSSO Token',
                          style: GoogleFonts.inter(
                            color: textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Spacer(),
                        if (_hasDetectedToken)
                          Text(
                            'Detected',
                            style: GoogleFonts.inter(
                              color: neonGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _tokenController,
                      onChanged: (_) => setState(() {}),
                      maxLines: 2,
                      minLines: 1,
                      cursorColor: primaryAccentColor,
                      style: TextStyle(color: textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Import from clipboard or paste manually',
                        hintStyle: TextStyle(color: textMuted, fontSize: 12),
                        filled: true,
                        fillColor: Colors.black.withValues(alpha: 0.14),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: primaryAccentColor.withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14),
              _PrimaryPillButton(
                onPressed: _hasDetectedToken ? _complete : null,
                icon: Icons.link_rounded,
                label: _hasDetectedToken ? 'CONNECT PSN' : 'WAITING FOR TOKEN',
              ),
              SizedBox(height: 10),
              _GhostPillButton(
                onPressed: _connectDemoData,
                icon: Icons.science_rounded,
                label: 'USE DEMO DATA',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineStatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _InlineStatusPill({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PrimaryPillButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;

  const _PrimaryPillButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 52),
        backgroundColor: primaryAccentColor.withValues(alpha: 0.2),
        foregroundColor: primaryAccentColor,
        disabledBackgroundColor: primaryAccentColor.withValues(alpha: 0.08),
        disabledForegroundColor: textMuted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: primaryAccentColor.withValues(alpha: 0.34)),
        ),
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: GoogleFonts.orbitron(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _GhostPillButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;

  const _GhostPillButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 48),
        foregroundColor: textPrimary,
        backgroundColor: Colors.white.withValues(alpha: 0.04),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: GoogleFonts.orbitron(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: textPrimary),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
