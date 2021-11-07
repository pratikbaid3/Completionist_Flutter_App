import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:game_trophy_manager/Model/Enum/game_guide_filter_enum.dart';
import 'package:game_trophy_manager/Model/game_guide_model.dart';
import 'package:game_trophy_manager/Model/game_model.dart';
import 'package:game_trophy_manager/Provider/ps4_guide_provider.dart';
import 'package:game_trophy_manager/Provider/internal_db_provider.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:game_trophy_manager/Widgets/ps4_guide_card.dart';
import 'package:game_trophy_manager/Widgets/snack_bar.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class Ps4GuidePage extends StatefulWidget {
  GameModel game;

  Ps4GuidePage({@required this.game});

  @override
  _Ps4GuidePageState createState() => _Ps4GuidePageState();
}

class _Ps4GuidePageState extends State<Ps4GuidePage> {
  bool isExpanded = false;
  bool isGameAdded = false;
  GameGuideFilterEnum filter = GameGuideFilterEnum.All;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeGameState();
  }

  Future initializeGameState() async {
    List<GameModel> myGames =
        Provider.of<InternalDbProvider>(context, listen: false).myGames;
    for (GameModel g in myGames) {
      if (g.gameName == widget.game.gameName) {
        setState(() {
          isGameAdded = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double hp = MediaQuery.of(context).size.height;
    double wp = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: secondaryColor,
        elevation: 1,
        actions: [
          PopupMenuButton<String>(
            color: primaryAccentColor,
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            onSelected: (value) {
              if (value == 'Add Game') {
                Provider.of<InternalDbProvider>(context, listen: false)
                    .addGameToDb(widget.game, context);
                snackBar(context, 'Added',
                    "${widget.game.gameName} has been added", wp);
              }
              if (value == 'Remove Game') {
                Provider.of<InternalDbProvider>(context, listen: false)
                    .removeGameFromDb(widget.game, context);
                snackBar(context, 'Removed',
                    "${widget.game.gameName} has been removed", wp);
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Add Game', 'Remove Game'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(12.0),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: wp * 0.03, vertical: hp * 0.03),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
                child: Neumorphic(
                  style: NeumorphicStyle(
                    surfaceIntensity: 0,
                    depth: 6,
                    lightSource: LightSource.topLeft,
                    color: primaryColor,
                    shape: NeumorphicShape.flat,
                    shadowDarkColor: Color(0xff232831),
                    shadowLightColor: Color(0xff2B313C),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Hero(
                      tag: '${widget.game.gameName}',
                      child: CachedNetworkImage(
                        imageUrl: widget.game.gameImageUrl,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: double.infinity,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 15),
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<GameGuideFilterEnum>(
                        dropdownColor: primaryAccentColor,
                        focusColor: primaryAccentColor,
                        value: filter,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        iconEnabledColor: Colors.white,
                        items: GameGuideFilterEnum.values
                            .map((GameGuideFilterEnum filterType) {
                          return DropdownMenuItem<GameGuideFilterEnum>(
                              value: filterType,
                              child: Text(filterType.toString().split('.')[1]));
                        }).toList(),
                        onChanged: (GameGuideFilterEnum value) {
                          setState(() {
                            filter = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              FutureBuilder(
                future: Provider.of<PS4GuideProvider>(context)
                    .getGuide(gameName: widget.game.gameName),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (Provider.of<PS4GuideProvider>(context).guide.length ==
                      0) {
                    return Container(
                      height: hp * 0.6,
                      child: Center(
                        child: SpinKitFadingCircle(
                          color: primaryAccentColor,
                          size: 60.0,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 10, left: 2, right: 2),
                    itemCount:
                        Provider.of<PS4GuideProvider>(context).guide.length,
                    itemBuilder: (BuildContext context, int index) {
                      bool isCompleted = false;
                      bool isStarred = false;
                      String trophyName = Provider.of<PS4GuideProvider>(context)
                          .guide[index]
                          .trophyName;

                      //Filter through internal DB to check which trophies are completed
                      for (GuideModel guide
                          in Provider.of<InternalDbProvider>(context)
                              .myCompletedTrophy) {
                        if (guide.trophyName == trophyName) {
                          isCompleted = true;
                        }
                      }
                      //Filter through internal DB to check which trophies are starred
                      for (GuideModel guide
                          in Provider.of<InternalDbProvider>(context)
                              .myStarredTrophy) {
                        if (guide.trophyName == trophyName) {
                          isStarred = true;
                        }
                      }

                      //Applying the filter from the dropdown
                      if (filter == GameGuideFilterEnum.Completed &&
                          isCompleted) {
                        //If the filter is set to Completed and the trophy has been marked as completed
                        return PS4GuideCard(
                          index: index,
                          game: widget.game,
                          isStarred: isStarred,
                          isCompleted: isCompleted,
                        );
                      } else if (filter == GameGuideFilterEnum.Incomplete &&
                          !isCompleted) {
                        //If the filter is set to Incomplete and the trophy has been marked as incomplete
                        return PS4GuideCard(
                          index: index,
                          game: widget.game,
                          isStarred: isStarred,
                          isCompleted: isCompleted,
                        );
                      } else if (filter == GameGuideFilterEnum.All) {
                        //If the filter is set to all
                        return PS4GuideCard(
                          index: index,
                          game: widget.game,
                          isStarred: isStarred,
                          isCompleted: isCompleted,
                        );
                      }
                      return Container();
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
