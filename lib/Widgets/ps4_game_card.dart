import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:game_trophy_manager/Model/game_model.dart';
import 'package:game_trophy_manager/Provider/ad_state_provider.dart';
import 'package:game_trophy_manager/Provider/in_app_purchase_provider.dart';
import 'package:game_trophy_manager/Provider/ps4_guide_provider.dart';
import 'package:game_trophy_manager/Router/router_constant.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class PS4GameCard extends StatefulWidget {
  GameModel game;

  PS4GameCard({@required this.game});

  @override
  State<PS4GameCard> createState() => _PS4GameCardState();
}

class _PS4GameCardState extends State<PS4GameCard> {
  InterstitialAd interstitialAd;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (!Provider.of<InAppPurchaseProvider>(context)
        .isPremiumVersionPurchased) {
      final adState = Provider.of<AdStateProvider>(context);
      adState.initialization.then((status) {
        setState(() {
          InterstitialAd.load(
            adUnitId: adState.interstitialAdUnitId,
            request: AdRequest(),
            adLoadCallback: InterstitialAdLoadCallback(
              onAdLoaded: (InterstitialAd ad) {
                interstitialAd = ad;
              },
              onAdFailedToLoad: (LoadAdError error) {
                print('InterstitialAd failed to load: $error');
              },
            ),
          );
        });
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (interstitialAd != null) interstitialAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
      margin: new EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          Provider.of<PS4GuideProvider>(context, listen: false)
              .clearGuideList();
          Navigator.of(context)
              .pushNamed(guidePageRoute, arguments: widget.game)
              .then((value) {
            if (interstitialAd != null &&
                !Provider.of<InAppPurchaseProvider>(context, listen: false)
                    .isPremiumVersionPurchased) {
              interstitialAd.show();
            }
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: new BorderRadius.all(const Radius.circular(10)),
          ),
          child: ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 13.0),
            leading: Container(
                padding: EdgeInsets.only(right: 12.0),
                decoration: new BoxDecoration(
                    border: new Border(
                        right:
                            new BorderSide(width: 1.0, color: Colors.white24))),
                child: Hero(
                  tag: '${widget.game.gameName}',
                  child: CachedNetworkImage(
                    imageUrl: widget.game.gameImageUrl,
                    placeholder: (context, url) =>
                        new CircularProgressIndicator(
                      backgroundColor: primaryAccentColor,
                    ),
                    errorWidget: (context, url, error) => new Icon(Icons.error),
                  ),
                )),
            title: Text(
              '${widget.game.gameName}',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            trailing: Icon(Icons.keyboard_arrow_right,
                color: Colors.white, size: 30.0),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Row(
                children: [
                  Row(
                    children: <Widget>[
                      Icon(
                        LineAwesomeIcons.trophy,
                        color: goldenColor,
                        size: 25,
                      ),
                      Text(
                        ' ' + widget.game.gold,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Icon(
                        LineAwesomeIcons.trophy,
                        color: silverColor,
                        size: 25,
                      ),
                      Text(
                        ' ' + widget.game.silver,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Icon(
                        LineAwesomeIcons.trophy,
                        color: bronzeColor,
                        size: 25,
                      ),
                      Text(
                        ' ' + widget.game.bronze,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
