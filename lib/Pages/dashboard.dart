import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:neumorphic/neumorphic.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Widget> recentGames = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
            ),
            CarouselSlider(
              viewportFraction: 0.48,
              autoPlay: true,
              enlargeCenterPage: true,
              pauseAutoPlayOnTouch: Duration(seconds: 2),
              items: [1, 2, 3, 4, 5].map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(color: primaryColor),
                      child: NeuCard(
                        curveType: CurveType.flat,
                        bevel: 7,
                        decoration: NeumorphicDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: primaryColor,
                        ),
                        child: ClipRRect(
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: CachedNetworkImage(
                              imageUrl:
                                  'https://img.playstationtrophies.org/images/game/10533/cover.jpg',
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}
