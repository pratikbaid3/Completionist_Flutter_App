import 'dart:io';
import 'package:game_trophy_manager/Utilities/api.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdStateProvider {
  Future<InitializationStatus> initialization;

  AdStateProvider({this.initialization});

  //Ad unit ID
  //Banner
  //Android: ca-app-pub-9881507895831818/8126954189
  //iOS: ca-app-pub-9881507895831818/2136260901
  String get bannerAdUnitId => Platform.isAndroid
      ? isTestEnv
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-9881507895831818/3122900869'
      : isTestEnv
          ? 'ca-app-pub-3940256099942544/2934735716'
          : 'ca-app-pub-9881507895831818/2136260901';

  //Interstitial
  //Android: ca-app-pub-9881507895831818/3788269832
  //iOS: ca-app-pub-9881507895831818/8973131997
  String get interstitialAdUnitId => Platform.isAndroid
      ? isTestEnv
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-9881507895831818/3788269832'
      : isTestEnv
          ? 'ca-app-pub-3940256099942544/4411468910'
          : 'ca-app-pub-9881507895831818/8973131997';
}
