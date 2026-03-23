import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:game_trophy_manager/Model/game_model.dart';
import 'package:game_trophy_manager/Widgets/ps4_game_card.dart';
import 'package:game_trophy_manager/Provider/ps4_game_provider.dart';
import 'package:game_trophy_manager/Utilities/api.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

class AllPS4GamesPage extends StatefulWidget {
  final String gamesEndpoint;
  final String guideEndpoint;

  const AllPS4GamesPage({
    Key? key,
    this.gamesEndpoint = ps4GamesUrl,
    this.guideEndpoint = ps4GuideUrl,
  }) : super(key: key);

  @override
  _AllPS4GamesPageState createState() => _AllPS4GamesPageState();
}

class _AllPS4GamesPageState extends State<AllPS4GamesPage> {
  final PagingController<int, GameModel> _pagingController =
      PagingController(firstPageKey: 1);
  TextEditingController searchController = TextEditingController();
  bool isSearchIcon = true;
  String searchKeyword = '';
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchFocus.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      Provider.of<PS4GameProvider>(context, listen: false).getGame(
          pagingController: _pagingController,
          pageKey: pageKey,
          search: searchKeyword,
          endpoint: widget.gamesEndpoint);
    });
  }

  void _performSearch() {
    _searchFocus.unfocus();
    setState(() {
      searchKeyword = searchController.text;
      isSearchIcon = searchController.text.isEmpty;
      _pagingController.refresh();
    });
  }

  void _clearSearch() {
    _searchFocus.unfocus();
    setState(() {
      isSearchIcon = true;
      searchController.clear();
      searchKeyword = '';
      _pagingController.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              _buildSearchBar()
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: -0.2, end: 0, duration: 300.ms),
              SizedBox(height: 12),
              Expanded(
                child: PagedListView<int, GameModel>(
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate<GameModel>(
                    itemBuilder: (context, item, index) =>
                        PS4GameCard(game: item, guideEndpoint: widget.guideEndpoint),
                    firstPageProgressIndicatorBuilder: (_) => Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: CircularProgressIndicator(color: primaryAccentColor, strokeWidth: 2),
                      ),
                    ),
                    newPageProgressIndicatorBuilder: (_) => Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(color: primaryAccentColor, strokeWidth: 2),
                      ),
                    ),
                    noItemsFoundIndicatorBuilder: (_) => _buildNoResults(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _searchFocus.hasFocus
              ? primaryAccentColor.withValues(alpha: 0.5)
              : primaryAccentColor.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(color: primaryAccentColor.withValues(alpha: 0.05), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: TextField(
        focusNode: _searchFocus,
        onSubmitted: (_) => _performSearch(),
        cursorColor: primaryAccentColor,
        controller: searchController,
        style: GoogleFonts.inter(color: textPrimary, fontSize: 15),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search_rounded, color: textMuted, size: 22),
          suffixIcon: isSearchIcon
              ? IconButton(onPressed: _performSearch, icon: Icon(Icons.arrow_forward_rounded, color: primaryAccentColor, size: 22))
              : IconButton(onPressed: _clearSearch, icon: Icon(Icons.close_rounded, color: textMuted, size: 22)),
          border: InputBorder.none,
          hintText: 'Search games...',
          hintStyle: TextStyle(color: textMuted, fontSize: 15),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: textMuted),
            SizedBox(height: 16),
            Text('No games found', style: GoogleFonts.inter(color: textSecondary, fontWeight: FontWeight.w600, fontSize: 16)),
            SizedBox(height: 4),
            Text('Try a different search term', style: TextStyle(color: textMuted, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
