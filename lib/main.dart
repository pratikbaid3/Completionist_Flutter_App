import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:game_trophy_manager/Provider/in_app_purchase_provider.dart';
import 'package:game_trophy_manager/Provider/internal_db_provider.dart';
import 'package:game_trophy_manager/Router/router.dart' as router;
import 'package:game_trophy_manager/Router/router_constant.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'Provider/ad_state_provider.dart';
import 'Provider/ps4_game_provider.dart';
import 'Provider/ps4_guide_provider.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

void main() {
  if (defaultTargetPlatform == TargetPlatform.android) {
    InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  }
  WidgetsFlutterBinding.ensureInitialized();
  final initFuture = MobileAds.instance.initialize();
  final adStateProvider = AdStateProvider(initialization: initFuture);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(Provider.value(
      value: adStateProvider,
      builder: (context, child) => MyApp(),
    ));
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<PS4GameProvider>(
            create: (context) => PS4GameProvider(),
          ),
          ChangeNotifierProvider<PS4GuideProvider>(
            create: (context) => PS4GuideProvider(),
          ),
          ChangeNotifierProvider<InternalDbProvider>(
            create: (context) => InternalDbProvider(),
          ),
          ChangeNotifierProvider<InAppPurchaseProvider>(
            create: (context) => InAppPurchaseProvider(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark().copyWith(
              primaryColor: primaryColor,
              scaffoldBackgroundColor: primaryColor,
              accentColor: primaryColor),
          onGenerateRoute: router.generateRoute,
          initialRoute: splashScreenRoute,
        ),
      ),
    );
  }
}
