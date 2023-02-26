import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsCubit extends Cubit<bool> {
  static AdsCubit of(BuildContext context) =>
      BlocProvider.of<AdsCubit>(context);

  final bool releaseMode;

  AdsCubit({this.releaseMode = true}) : super(false);

  BannerAd? bannerAd;
  InterstitialAd? _interstitialAd;

  Future<void> init() async {
    await FirebaseRemoteConfig.instance.fetchAndActivate();

    if (FirebaseRemoteConfig.instance.getBool("banner")) {
      _initBanner();
    }
    if (FirebaseRemoteConfig.instance.getBool("interstitial")) {
      _initInterstitialAd();
    }
  }

  Future<void> _initBanner() async {
    String adUnitId = releaseMode
        ? "ca-app-pub-7519220681088057/7416942476"
        : "ca-app-pub-3940256099942544/6300978111";
    bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: adUnitId,
        listener: BannerAdListener(
          onAdLoaded: (_) => emit(true),
          onAdClicked: (_) =>
              FirebaseAnalytics.instance.logEvent(name: "banner_clicked"),
          onAdImpression: (_) =>
              FirebaseAnalytics.instance.logEvent(name: "banner_impression"),
          onAdFailedToLoad: (ad, error) => print(error),
        ),
        request: const AdRequest());
    bannerAd?.load();
  }

  Future<void> _initInterstitialAd() async {
    String adUnitId = releaseMode
        ? "ca-app-pub-7519220681088057/5808227810"
        : "ca-app-pub-3940256099942544/1033173712";
    InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            FirebaseAnalytics.instance.logEvent(name: "loaded_interstitial");
          },
          onAdFailedToLoad: print,
        ));
  }

  Future<void> showAd() async {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      FirebaseAnalytics.instance.logEvent(name: "show_interstitial");
    }
    
  }
}
