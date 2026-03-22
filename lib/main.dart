import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:game_trophy_manager/Provider/in_app_purchase_provider.dart';
import 'package:game_trophy_manager/Provider/internal_db_provider.dart';
import 'package:game_trophy_manager/Router/router.dart' as router;
import 'package:game_trophy_manager/Router/router_constant.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'Provider/ad_state_provider.dart';
import 'Provider/ps4_game_provider.dart';
import 'Provider/ps4_guide_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final initFuture = MobileAds.instance.initialize();
  final adStateProvider = AdStateProvider(initialization: initFuture);

  // Set system UI overlay style for immersive dark theme
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: secondaryColor,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

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
            canvasColor: surfaceColor,
            cardColor: cardColor,
            colorScheme: ColorScheme.dark(
              primary: primaryAccentColor,
              secondary: secondaryAccentColor,
              surface: surfaceColor,
              error: neonPink,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: primaryColor,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              centerTitle: true,
              titleTextStyle: GoogleFonts.orbitron(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
                letterSpacing: 2,
              ),
              iconTheme: IconThemeData(color: textPrimary),
            ),
            textTheme: GoogleFonts.interTextTheme(
              ThemeData.dark().textTheme,
            ).apply(
              bodyColor: textPrimary,
              displayColor: textPrimary,
            ),
            iconTheme: IconThemeData(color: textPrimary),
            dividerTheme: DividerThemeData(
              color: textMuted.withValues(alpha: 0.2),
              thickness: 1,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryAccentColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                textStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintStyle: TextStyle(color: textMuted),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            progressIndicatorTheme: ProgressIndicatorThemeData(
              color: primaryAccentColor,
            ),
            expansionTileTheme: ExpansionTileThemeData(
              iconColor: textSecondary,
              collapsedIconColor: textMuted,
            ),
          ),
          onGenerateRoute: router.generateRoute,
          initialRoute: splashScreenRoute,
        ),
      ),
    );
  }
}
