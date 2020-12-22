import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:game_trophy_manager/Provider/internal_db_provider.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:game_trophy_manager/Widgets/line_chart.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:provider/provider.dart';

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
              items: Provider.of<InternalDbProvider>(context).myGames.map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(color: primaryColor),
                      child: NeuCard(
                        curveType: CurveType.flat,
                        bevel: 6,
                        decoration: NeumorphicDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: primaryColor,
                        ),
                        child: ClipRRect(
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: CachedNetworkImage(
                              imageUrl: i.gameImageUrl,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LineChartSample2(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
