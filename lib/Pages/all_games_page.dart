import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_trophy_manager/Model/game_model.dart';
import 'package:game_trophy_manager/Provider/game_provider.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:provider/provider.dart';

class AllGamesPage extends StatefulWidget {
  @override
  _AllGamesPageState createState() => _AllGamesPageState();
}

class _AllGamesPageState extends State<AllGamesPage> {
  TextEditingController searchController = new TextEditingController();
  bool isSearchIcon = true;

  void GetData() async {
    List<GameModel> games =
        await Provider.of<GameProvider>(context, listen: false).getGame();
    print(games[0].gameName);
  }

  @override
  void initState() {
    // TODO: implement initState
    GetData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double hp = MediaQuery.of(context).size.height;
    double wp = MediaQuery.of(context).size.width;
    return KeyboardDismissOnTap(
      child: Scaffold(
        body: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: wp * 0.03, vertical: hp * 0.03),
          child: Column(
            children: [
              TextField(
                cursorColor: primaryAccentColor,
                controller: searchController,
                decoration: InputDecoration(
                  suffixIcon: (isSearchIcon)
                      ? IconButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            setState(() {
                              isSearchIcon = false;
                            });
                            //TODO Execute search
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
                  contentPadding:
                      EdgeInsets.only(left: 20, bottom: 20, top: 20, right: 20),
                ),
              ),
              SizedBox(
                height: hp * 0.02,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
