import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_trophy_manager/Pages/all_games_page.dart';
import 'package:game_trophy_manager/Pages/dashboard.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:game_trophy_manager/Utilities/reusable_elements.dart';
import 'package:game_trophy_manager/Widgets/nav_drawer_list_tile.dart';
import 'package:hidden_drawer_menu/controllers/simple_hidden_drawer_controller.dart';
import 'package:hidden_drawer_menu/simple_hidden_drawer/simple_hidden_drawer.dart';

class NavDrawerPage extends StatefulWidget {
  @override
  _NavDrawerPageState createState() => _NavDrawerPageState();
}

class _NavDrawerPageState extends State<NavDrawerPage> {
  @override
  Widget build(BuildContext context) {
    double hp = MediaQuery.of(context).size.height;
    double wp = MediaQuery.of(context).size.width;
    return SimpleHiddenDrawer(
      withShadow: true,
      slidePercent: wp * 0.15,
      contentCornerRadius: 40,
      menu: Menu(),
      screenSelectedBuilder: (position, controller) {
        Widget screenCurrent;
        switch (position) {
          case 0:
            screenCurrent = Dashboard();
            break;
          case 1:
            screenCurrent = AllGamesPage();
            break;
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () {
                controller.toggle();
              },
            ),
            centerTitle: true,
            backgroundColor: secondaryColor,
            elevation: 1,
            // title: Image(
            //   height: 35,
            //   image: AssetImage('images/icons/hustle_logo.png'),
            // ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
              // IconButton(
              //   icon: Icon(
              //     Icons.search,
              //     color: Colors.white,
              //   ),
              //   onPressed: () {},
              // ),
            ],
          ),
          body: screenCurrent,
        );
      },
    );
  }
}

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  SimpleHiddenDrawerController controller;

  @override
  void didChangeDependencies() {
    controller = SimpleHiddenDrawerController.of(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    double hp = MediaQuery.of(context).size.height;
    double wp = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [primaryAccentColor, secondaryAccentColor],
          ),
        ),
        width: double.maxFinite,
        height: double.maxFinite,
        padding: const EdgeInsets.only(top: 30.0, left: 5),
        child: ListView(
          shrinkWrap: true,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Image(
                //   width: wp * 0.4,
                //   height: wp * 0.4,
                //   image: AssetImage(
                //     'images/drawer_image.png',
                //   ),
                // ),
              ],
            ),
            SizedBox(
              height: hp * 0.01,
            ),
            NavDrawerListTile(
                icon: Icons.dashboard,
                onTap: () {
                  controller.position = 0;
                  controller.toggle();
                },
                title: 'Dashboard'),
            NavDrawerListTile(
                icon: FontAwesomeIcons.gamepad,
                onTap: () {
                  controller.toggle();
                  controller.position = 2;
                },
                title: 'My Games'),
            NavDrawerListTile(
                icon: FontAwesomeIcons.playstation,
                onTap: () {
                  controller.position = 1;
                  controller.toggle();
                },
                title: 'PS4 Games'),
            NavDrawerListTile(
                icon: FontAwesomeIcons.xbox,
                onTap: () {
                  controller.position = 1;
                  controller.toggle();
                },
                title: 'Xbox Games'),
            NavDrawerListTile(
                icon: Icons.star,
                onTap: () {
                  controller.position = 1;
                  controller.toggle();
                },
                title: 'Starred'),
            NavDrawerListTile(
                icon: Icons.info,
                onTap: () {
                  controller.toggle();
                },
                title: 'About'),
          ],
        ),
      ),
    );
  }
}
