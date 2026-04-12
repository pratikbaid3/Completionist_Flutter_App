import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:game_trophy_manager/Widgets/aurora_background.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_trophy_manager/Pages/PS4/ps4_games_page.dart';
import 'package:game_trophy_manager/Pages/dashboard.dart';
import 'package:game_trophy_manager/Pages/my_completed_trophies_page.dart';
import 'package:game_trophy_manager/Pages/my_starred_trophies_page.dart';
import 'package:game_trophy_manager/Provider/internal_db_provider.dart';
import 'package:game_trophy_manager/Provider/psn_sync_provider.dart';
import 'package:game_trophy_manager/Utilities/analytics.dart';
import 'package:game_trophy_manager/Utilities/api.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'my_games_page.dart';

class NavDrawerPage extends StatefulWidget {
  @override
  _NavDrawerPageState createState() => _NavDrawerPageState();
}

class _NavDrawerPageState extends State<NavDrawerPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabAnimController;
  final List<_NavItem> _navItems = [
    _NavItem(Icons.dashboard_rounded, 'Home'),
    _NavItem(Icons.gamepad_rounded, 'My Games'),
    _NavItem(FontAwesomeIcons.playstation, 'Browse'),
    _NavItem(Icons.emoji_events_rounded, 'Trophies'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshPsnIfNeeded();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _fabAnimController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPsnIfNeeded();
    }
  }

  static const _tabNames = ['Home', 'My Games', 'Browse', 'Trophies'];

  void _onTabTapped(int index) {
    HapticFeedback.lightImpact();
    Analytics.logTabSwitch(_tabNames[index]);
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _refreshPsnIfNeeded() async {
    final dbProvider = Provider.of<InternalDbProvider>(context, listen: false);
    await Provider.of<PsnSyncProvider>(context, listen: false)
        .refreshIfStale(dbProvider);
  }

  @override
  Widget build(BuildContext context) {
    double wp = MediaQuery.of(context).size.width;
    final dbProvider = Provider.of<InternalDbProvider>(context);
    final psnProvider = Provider.of<PsnSyncProvider>(context);
    final syncPreviewImages =
        _collectSyncPreviewImages(dbProvider, psnProvider);
    return Scaffold(
      backgroundColor: primaryColor,
      extendBody: true,
      appBar: _buildAppBar(wp, psnProvider, dbProvider),
      body: AuroraBackground(
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                HapticFeedback.selectionClick();
                Analytics.logTabSwitch(_tabNames[index]);
                setState(() => _currentIndex = index);
              },
              children: [
                Dashboard(),
                MyGamesPage(),
                _BrowseTabView(),
                _TrophiesTabView(),
              ],
            ),
            if (psnProvider.isBusy)
              Positioned.fill(
                child: _PsnSyncLoadingBottomSheet(
                  psnProvider: psnProvider,
                  imageUrls: syncPreviewImages,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: AbsorbPointer(
        absorbing: psnProvider.isBusy,
        child: _buildBottomNav(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    double wp,
    PsnSyncProvider psnProvider,
    InternalDbProvider dbProvider,
  ) {
    final isConnected = psnProvider.isConnected && psnProvider.profile != null;
    final avatarUrl = isConnected ? psnProvider.profile!.avatarUrl.trim() : '';

    return AppBar(
      backgroundColor: primaryColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: Row(
        children: [
          ClipOval(
            child: Image.asset(
              'images/app_icon.png',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 10),
          Text(
            'COMPLETIONIST',
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
      actions: [
        if (isConnected)
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: psnProvider.isBusy
                  ? null
                  : () => _showPsnAccountSheet(psnProvider, dbProvider),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryAccentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(1000),
                  border: Border.all(
                    color: primaryAccentColor.withValues(alpha: 0.26),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPsnAvatar(
                      avatarUrl: avatarUrl,
                      radius: 13,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                primaryAccentColor.withValues(alpha: 0.3),
                secondaryAccentColor.withValues(alpha: 0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPsnAvatar({
    required String avatarUrl,
    required double radius,
  }) {
    final size = radius * 2;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: surfaceColor,
      ),
      clipBehavior: Clip.antiAlias,
      child: avatarUrl.isNotEmpty
          ? Image.network(
              avatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _avatarFallbackIcon(radius),
            )
          : _avatarFallbackIcon(radius),
    );
  }

  Widget _avatarFallbackIcon(double radius) {
    return Center(
      child: Icon(
        Icons.person_rounded,
        size: radius,
        color: textPrimary,
      ),
    );
  }

  Future<void> _showPsnAccountSheet(
    PsnSyncProvider psnProvider,
    InternalDbProvider dbProvider,
  ) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final name = psnProvider.profile?.onlineId.isNotEmpty == true
            ? psnProvider.profile!.onlineId
            : 'Connected account';
        final avatarUrl = psnProvider.profile?.avatarUrl ?? '';
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
                        _buildPsnAvatar(
                          avatarUrl: avatarUrl,
                          radius: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.inter(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                psnProvider.lastSyncLabel(),
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: psnProvider.isBusy
                            ? null
                            : () async {
                                await psnProvider.syncNow(
                                  dbProvider,
                                  force: true,
                                );
                                if (!mounted) return;
                                Navigator.of(sheetContext).pop();
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textPrimary,
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.14),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: Icon(Icons.refresh_rounded, size: 18),
                        label: Text('Refresh'),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: psnProvider.isBusy
                            ? null
                            : () async {
                                await psnProvider.disconnect(dbProvider);
                                if (!mounted) return;
                                Navigator.of(sheetContext).pop();
                              },
                        style: TextButton.styleFrom(
                          foregroundColor: neonPink,
                          backgroundColor: neonPink.withValues(alpha: 0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: Icon(Icons.link_off_rounded, size: 18),
                        label: Text('Disconnect PSN'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: secondaryColor.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: primaryAccentColor.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final isSelected = _currentIndex == index;
              return _NavBarItem(
                item: _navItems[index],
                isSelected: isSelected,
                onTap: () => _onTabTapped(index),
              );
            }),
          ),
        ),
      ),
    );
  }

  List<String> _collectSyncPreviewImages(
    InternalDbProvider dbProvider,
    PsnSyncProvider psnProvider,
  ) {
    final seen = <String>{};
    final urls = <String>[];

    void append(String raw) {
      final url = raw.trim();
      if (url.isEmpty) return;
      if (seen.add(url)) {
        urls.add(url);
      }
    }

    for (final url in psnProvider.busyImageUrls) {
      append(url);
    }
    for (final game in dbProvider.myPsnGames) {
      append(game.imageUrl);
    }
    for (final game in dbProvider.myGames) {
      append(game.gameImageUrl);
    }

    if (urls.length > 20) {
      return urls.sublist(0, 20);
    }
    return urls;
  }
}

class _BrowseTabView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: glassDecoration(borderRadius: 12, opacity: 0.05),
            child: TabBar(
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: accentGradient,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: textSecondary,
              labelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FontAwesomeIcons.playstation, size: 14),
                      SizedBox(width: 6),
                      Text('PS4'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FontAwesomeIcons.playstation, size: 14),
                      SizedBox(width: 6),
                      Text('PS5'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                AllPS4GamesPage(
                  gamesEndpoint: ps4GamesUrl,
                  guideEndpoint: ps4GuideUrl,
                ),
                AllPS4GamesPage(
                  gamesEndpoint: ps5GamesUrl,
                  guideEndpoint: ps5GuideUrl,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrophiesTabView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: glassDecoration(borderRadius: 12, opacity: 0.05),
            child: TabBar(
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: accentGradient,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: textSecondary,
              labelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Completed'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Starred'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                MyCompletedTrophyPage(),
                MyStarredTrophyPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PsnSyncLoadingBottomSheet extends StatefulWidget {
  final PsnSyncProvider psnProvider;
  final List<String> imageUrls;

  const _PsnSyncLoadingBottomSheet({
    required this.psnProvider,
    required this.imageUrls,
  });

  @override
  State<_PsnSyncLoadingBottomSheet> createState() =>
      _PsnSyncLoadingBottomSheetState();
}

class _PsnSyncLoadingBottomSheetState extends State<_PsnSyncLoadingBottomSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  late final PageController _pageController;
  Timer? _carouselTimer;
  int _activePage = 0;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pageController = PageController(viewportFraction: 0.58);
    _restartCarouselTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _isVisible = true);
    });
  }

  @override
  void didUpdateWidget(covariant _PsnSyncLoadingBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrls.length != widget.imageUrls.length) {
      if (_activePage >= widget.imageUrls.length) {
        _activePage = 0;
      }
      _restartCarouselTimer();
    }
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _restartCarouselTimer() {
    _carouselTimer?.cancel();
    if (widget.imageUrls.length <= 1) return;

    _carouselTimer = Timer.periodic(Duration(seconds: 6), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final itemCount = widget.imageUrls.length;
      if (itemCount <= 1) return;
      _activePage = (_activePage + 1) % itemCount;
      _pageController.animateToPage(
        _activePage,
        duration: Duration(milliseconds: 900),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.psnProvider.busyTitle.isNotEmpty
        ? widget.psnProvider.busyTitle
        : 'Syncing your PSN data';
    final message = widget.psnProvider.busyMessage.isNotEmpty
        ? widget.psnProvider.busyMessage
        : 'Please wait while we import your latest library.';
    final elapsed = widget.psnProvider.busyElapsedLabel();

    return Stack(
      children: [
        ModalBarrier(
          dismissible: false,
          color: Colors.black.withValues(alpha: 0.38),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            top: false,
            child: AnimatedSlide(
              offset: _isVisible ? Offset.zero : Offset(0, 0.2),
              duration: Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 12, 6),
                child: AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    final glow = 0.16 + (_glowController.value * 0.18);
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          padding: EdgeInsets.fromLTRB(16, 12, 16, 18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                secondaryColor.withValues(alpha: 0.9),
                                primaryColor.withValues(alpha: 0.88),
                              ],
                            ),
                            border: Border.all(
                              color: primaryAccentColor.withValues(alpha: glow),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryAccentColor.withValues(
                                  alpha: glow * 0.45,
                                ),
                                blurRadius: 18,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 42,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: textMuted.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: primaryAccentColor.withValues(
                                        alpha: 0.15 +
                                            (_glowController.value * 0.1),
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          primaryAccentColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: GoogleFonts.inter(
                                        color: textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  if (elapsed.isNotEmpty)
                                    Text(
                                      elapsed,
                                      style: TextStyle(
                                        color: textMuted,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 10),
                              AnimatedSwitcher(
                                duration: Duration(milliseconds: 300),
                                child: Text(
                                  message,
                                  key: ValueKey<String>(message),
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 12.5,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              _buildCarousel(),
                              SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  minHeight: 5,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.08),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    primaryAccentColor.withValues(alpha: 0.88),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Sync in progress. Please keep the app open.',
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarousel() {
    if (widget.imageUrls.isEmpty) {
      return SizedBox(
        height: 138,
        child: Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryAccentColor.withValues(alpha: 0.16),
                      secondaryAccentColor.withValues(alpha: 0.14),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.09),
                  ),
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: textMuted.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final edgeMaskColor = secondaryColor.withValues(alpha: 0.94);
    final orbitAngle = _glowController.value * math.pi * 2;

    return Column(
      children: [
        SizedBox(
          height: 142,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const scanLensSize = 46.0;
              final centerX = (constraints.maxWidth - scanLensSize) / 2;
              final centerY = (142 - scanLensSize) / 2;
              final orbitRadiusX =
                  math.min(constraints.maxWidth * 0.18, 54).toDouble();
              const orbitRadiusY = 18.0;
              final scanLeft = centerX + (math.cos(orbitAngle) * orbitRadiusX);
              final scanTop = centerY + (math.sin(orbitAngle) * orbitRadiusY);

              return Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: widget.imageUrls.length,
                    onPageChanged: (index) =>
                        setState(() => _activePage = index),
                    itemBuilder: (context, index) {
                      final imageUrl = widget.imageUrls[index];
                      return Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              filterQuality: FilterQuality.high,
                              errorBuilder: (_, __, ___) => Container(
                                color: surfaceColor,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: textMuted,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.08),
                                    Colors.black.withValues(alpha: 0.22),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 46,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              edgeMaskColor,
                              edgeMaskColor.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: 46,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                              edgeMaskColor,
                              edgeMaskColor.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: centerX - 10,
                    top: centerY - 10,
                    child: IgnorePointer(
                      child: Container(
                        width: scanLensSize + 20,
                        height: scanLensSize + 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryAccentColor.withValues(alpha: 0.22),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: scanLeft,
                    top: scanTop,
                    child: IgnorePointer(
                      child: Container(
                        width: scanLensSize,
                        height: scanLensSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                          border: Border.all(
                            color: primaryAccentColor.withValues(alpha: 0.68),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryAccentColor.withValues(alpha: 0.2),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          color: textPrimary.withValues(alpha: 0.9),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (widget.imageUrls.length > 1) ...[
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.imageUrls.length, (index) {
              final isActive = index == _activePage;
              return AnimatedContainer(
                duration: Duration(milliseconds: 220),
                margin: EdgeInsets.symmetric(horizontal: 2),
                width: isActive ? 14 : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: isActive
                      ? primaryAccentColor
                      : textMuted.withValues(alpha: 0.4),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem(this.icon, this.label);
}

class _NavBarItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? primaryAccentColor.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? primaryAccentColor.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 20,
              color: isSelected ? primaryAccentColor : textMuted,
            ),
            if (isSelected) ...[
              SizedBox(width: 8),
              Text(
                item.label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primaryAccentColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
