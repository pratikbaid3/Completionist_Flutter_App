import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:game_trophy_manager/Model/game_guide_model.dart';
import 'package:game_trophy_manager/Model/game_model.dart';
import 'package:game_trophy_manager/Provider/guide_provider.dart';
import 'package:game_trophy_manager/Provider/internal_db_provider.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:game_trophy_manager/Widgets/ps4_guide_card.dart';
import 'package:game_trophy_manager/Widgets/snack_bar.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class GuidePage extends StatefulWidget {
  GameModel game;

  GuidePage({@required this.game});

  @override
  _GuidePageState createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  bool isExpanded = false;
  bool isGameAdded = false;

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
              // NeumorphicSwitch(
              //   style: NeumorphicSwitchStyle(),
              //   value: isGameAdded,
              //   onChanged: (val) {
              //     if (isGameAdded == true) {
              //       //Remove the game
              //       Provider.of<InternalDbProvider>(context, listen: false)
              //           .removeGameFromDb(widget.game, context);
              //       snackBar(context, 'Removed',
              //           "${widget.game.gameName} has been removed", wp);
              //     } else {
              //       //Add the game
              //       Provider.of<InternalDbProvider>(context, listen: false)
              //           .addGameToDb(widget.game, context);
              //       snackBar(context, 'Added',
              //           "${widget.game.gameName} has been added", wp);
              //     }
              //     setState(() {
              //       isGameAdded = (isGameAdded == false) ? true : false;
              //     });
              //     print(isGameAdded);
              //   },
              // ),

              FutureBuilder(
                future: Provider.of<GuideProvider>(context)
                    .getGuide(gameName: widget.game.gameName),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (Provider.of<GuideProvider>(context).guide.length == 0) {
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
                    itemCount: Provider.of<GuideProvider>(context).guide.length,
                    itemBuilder: (BuildContext context, int index) {
                      bool isCompleted = false;
                      bool isStarred = false;
                      String trophyName = Provider.of<GuideProvider>(context)
                          .guide[index]
                          .trophyName;
                      for (GuideModel guide
                          in Provider.of<InternalDbProvider>(context)
                              .myCompletedTrophy) {
                        if (guide.trophyName == trophyName) {
                          isCompleted = true;
                        }
                      }
                      for (GuideModel guide
                          in Provider.of<InternalDbProvider>(context)
                              .myStarredTrophy) {
                        if (guide.trophyName == trophyName) {
                          isStarred = true;
                        }
                      }
                      return PS4GuideCard(
                        index: index,
                        game: widget.game,
                        isStarred: isStarred,
                        isCompleted: isCompleted,
                      );
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
