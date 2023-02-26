import 'dart:io';

import 'package:calculator/bloc/calculator_cubit.dart';
import 'package:calculator/data/calculator_repository.dart';
import 'package:calculator/ui/calculator_text_editing_controller.dart';
import 'package:calculator/ui/formatter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/loaders/decoders/yaml_decode_strategy.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gesture_calculator/bloc/ads_cubit.dart';
import 'package:gesture_calculator/bloc/history_cubit.dart';
import 'package:gesture_calculator/bloc/review_cubit.dart';
import 'package:gesture_calculator/bloc/settings_cubit.dart';
import 'package:gesture_calculator/bloc/tutorial_cubit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'firebase_options.dart';
import 'ui/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase Tools
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Analytics
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Remote Config
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(hours: 24),
  ));
  await remoteConfig
      .setDefaults(const {"banner": false, "interstitial": false});

  // AdMob
  MobileAds.instance.initialize();

  // Google Fonts
  GoogleFonts.config.allowRuntimeFetching = false;

  // Local Storage with Hive
  HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: await getApplicationDocumentsDirectory());
  CalculatorRepository calculatorRepository = CalculatorRepository();

  // Launch App
  runApp(MyApp(calculatorRepository: calculatorRepository));
}

class MyApp extends StatelessWidget {
  final CalculatorRepository calculatorRepository;

  const MyApp({super.key, required this.calculatorRepository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => SettingsCubit(SettingsCubit.defaultState)
              ..handleFullscreenSettings()),
        BlocProvider(create: (_) => HistoryCubit(HistoryCubit.defaultState)),
        BlocProvider(
            create: (_) => ReviewCubit(ReviewCubit.defaultState)..appStarted()),
        BlocProvider(create: (_) => AdsCubit(releaseMode: true)..init()),
        BlocProvider(create: (_) => TutotialCubit()..init())
      ],
      child: Builder(builder: (context) {
        return BlocProvider<CalculatorCubit>(
          create: (_) => CalculatorCubit(
              CalculatorState(
                result: "",
                decimalPlaces: 3,
                useRadians: SettingsCubit.of(context).state.useRadians,
                isCalculating: false,
              ),
              textController: CalculatorTextEditingController(
                  Platform.localeName.contains("en")
                      ? SimpleFormatter.english()
                      : SimpleFormatter.nonenglish()), onResult: (result) {
            HistoryCubit.of(context).add(result);
          })
            ..init(),
          child: BlocBuilder<SettingsCubit, SettingsState>(
            buildWhen: (previous, current) =>
                previous.lightTheme != current.lightTheme,
            builder: (context, state) => MaterialApp(
              onGenerateTitle: (context) =>
                  FlutterI18n.translate(context, "app.title"),
              localizationsDelegates: [
                FlutterI18nDelegate(
                  translationLoader: FileTranslationLoader(
                      decodeStrategies: [YamlDecodeStrategy()]),
                ),
                ...GlobalMaterialLocalizations.delegates,
                GlobalWidgetsLocalizations.delegate
              ],
              supportedLocales: const [
                Locale("de"),
                Locale("en"),
              ],
              theme: state.lightTheme
                  ? ThemeData.light().copyWith(
                      textTheme: GoogleFonts.sourceSansProTextTheme(),
                      extensions: [lightTheme])
                  : ThemeData.dark().copyWith(
                      textTheme: GoogleFonts.sourceSansProTextTheme().copyWith(
                          headline5: const TextStyle(color: Colors.white),
                          bodyText2: const TextStyle(color: Colors.white),
                          caption: const TextStyle(color: Colors.white)),
                      extensions: [darkTheme]),
              home: BlocBuilder<TutotialCubit, int>(
                  builder: (context, tutorialState) {
                return AbsorbPointer(
                    absorbing: tutorialState != TutotialCubit.done,
                    child: const MainScreen());
              }),
            ),
          ),
        );
      }),
    );
  }
}
