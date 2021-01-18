import 'package:cached_network_image/cached_network_image.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:game_trophy_manager/Model/game_guide_model.dart';
import 'package:game_trophy_manager/Model/game_model.dart';
import 'package:game_trophy_manager/Provider/guide_provider.dart';
import 'package:game_trophy_manager/Provider/internal_db_provider.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:game_trophy_manager/Widgets/app_bar.dart';
import 'package:game_trophy_manager/Widgets/ps4_guide_card.dart';
import 'package:game_trophy_manager/Widgets/snack_bar.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:neumorphic/neumorphic.dart';
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
  int isGameAdded = 0;

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
          isGameAdded = 1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double hp = MediaQuery.of(context).size.height;
    double wp = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: BaseAppBar(
        appBar: AppBar(),
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
                child: NeuCard(
                  curveType: CurveType.flat,
                  bevel: 4,
                  decoration: NeumorphicDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: primaryColor,
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
              NeuSwitch<int>(
                thumbColor: secondaryColor,
                backgroundColor: primaryColor,
                onValueChanged: (val) {
                  if (isGameAdded == 1) {
                    //Remove the game
                    Provider.of<InternalDbProvider>(context, listen: false)
                        .removeGameFromDb(widget.game);
                    snackBar(context, 'Removed',
                        "${widget.game.gameName} has been removed", wp);
                  } else {
                    //Add the game
                    Provider.of<InternalDbProvider>(context, listen: false)
                        .addGameToDb(widget.game);
                    snackBar(context, 'Added',
                        "${widget.game.gameName} has been added", wp);
                  }
                  setState(() {
                    isGameAdded = (isGameAdded == 0) ? 1 : 0;
                  });
                  print(isGameAdded);
                },
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 7),
                groupValue: isGameAdded,
                children: {
                  0: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    child: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                  1: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                    child: Icon(
                      Icons.add,
                      color: Colors.green,
                    ),
                  ),
                },
              ),
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
