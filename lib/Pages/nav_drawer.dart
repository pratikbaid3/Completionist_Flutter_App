import 'package:flutter/material.dart';
import 'package:game_trophy_manager/Widgets/aurora_background.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_trophy_manager/Pages/PS4/ps4_games_page.dart';
import 'package:game_trophy_manager/Pages/dashboard.dart';
import 'package:game_trophy_manager/Pages/my_completed_trophies_page.dart';
import 'package:game_trophy_manager/Pages/my_starred_trophies_page.dart';
import 'package:game_trophy_manager/Utilities/analytics.dart';
import 'package:game_trophy_manager/Utilities/api.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'my_games_page.dart';

class NavDrawerPage extends StatefulWidget {
  @override
  _NavDrawerPageState createState() => _NavDrawerPageState();
}

class _NavDrawerPageState extends State<NavDrawerPage>
    with TickerProviderStateMixin {
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
    _pageController = PageController();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    double wp = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: primaryColor,
      extendBody: true,
      appBar: _buildAppBar(wp),
      body: AuroraBackground(
        child: PageView(
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
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar(double wp) {
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
      actions: [],
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

