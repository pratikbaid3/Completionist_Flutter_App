import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:game_trophy_manager/Model/game_model.dart';
import 'package:game_trophy_manager/Widgets/ps4_game_card.dart';
import 'package:game_trophy_manager/Provider/ps4_game_provider.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

class AllPS4GamesPage extends StatefulWidget {
  @override
  _AllPS4GamesPageState createState() => _AllPS4GamesPageState();
}

class _AllPS4GamesPageState extends State<AllPS4GamesPage> {
  final PagingController<int, GameModel> _pagingController =
      PagingController(firstPageKey: 1);
  TextEditingController searchController = new TextEditingController();
  bool isSearchIcon = true;
  String searchKeyword = '';

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      Provider.of<PS4GameProvider>(context, listen: false).getGame(
          pagingController: _pagingController,
          pageKey: pageKey,
          search: searchKeyword);
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    double hp = MediaQuery.of(context).size.height;
    double wp = MediaQuery.of(context).size.width;
    return KeyboardDismissOnTap(
      child: Scaffold(
        body: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: wp * 0.03, vertical: hp * 0.03),
            child: Column(
              children: [
                TextField(
                  onSubmitted: (value) {
                    setState(() {
                      searchKeyword = searchController.text;
                      isSearchIcon = false;
                      _pagingController.refresh();
                    });
                  },
                  cursorColor: primaryAccentColor,
                  controller: searchController,
                  decoration: InputDecoration(
                    suffixIcon: (isSearchIcon)
                        ? IconButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                searchKeyword = searchController.text;
                                isSearchIcon = false;
                                _pagingController.refresh();
                              });
                            },
                            icon: Icon(
                              Icons.search,
                              color: Colors.white54,
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                isSearchIcon = true;
                                searchController.text = '';
                                searchKeyword = searchController.text;
                                _pagingController.refresh();
                              });
                              //TODO Execute search
                            },
                            icon: Icon(
                              Icons.close,
                              color: Colors.white54,
                            ),
                          ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: primaryAccentColor,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: primaryColor,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    filled: true,
                    fillColor: secondaryColor,
                    hintText: "Search",
                    contentPadding: EdgeInsets.only(
                        left: 20, bottom: 20, top: 20, right: 20),
                  ),
                ),
                SizedBox(
                  height: hp * 0.02,
                ),
                Expanded(
                  child: PagedListView<int, GameModel>(
                    pagingController: _pagingController,
                    builderDelegate: PagedChildBuilderDelegate<GameModel>(
                      itemBuilder: (context, item, index) => PS4GameCard(
                        game: item,
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
