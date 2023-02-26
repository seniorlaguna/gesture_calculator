import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:gesture_calculator/bloc/ads_cubit.dart';
import 'package:gesture_calculator/bloc/review_cubit.dart';
import 'package:gesture_calculator/bloc/settings_cubit.dart';
import 'package:gesture_calculator/ui/index.dart';
import 'package:gesture_calculator/ui/widget/keyboard.dart';

import '../../bloc/tutorial_cubit.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  bool _showSecondKeyboard = false;
  final double _displayHeight = 0.375;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    SettingsCubit.of(context).handleFullscreenSettings();

    ReviewCubit.of(context).requestReview().then((value) {
      if (!value) AdsCubit.of(context).showAd();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final double width = mq.size.width;
    final double screenHeight =
        mq.size.height - mq.viewPadding.top - mq.viewPadding.bottom;

    return SafeArea(
      child: Scaffold(
        drawer: const PromoDrawer(),
        endDrawer: const SettingsDrawer(),
        body: TutorialMessage(
          tutorialStep: TutotialCubit.switchScientificKeyboardStep,
          callback: (context) {
            setState(() => _showSecondKeyboard = true);
            Future.delayed(const Duration(milliseconds: 1500), () {
              setState(() {
                _showSecondKeyboard = false;
              });
              TutotialCubit.of(context)
                  .goToState(TutotialCubit.openHistoryStep);
            });
          },
          child: TutorialMessage(
            tutorialStep: TutotialCubit.openSettingsStep,
            skipToStep: TutotialCubit.done,
            callback: (context) async {
              Scaffold.of(context).openEndDrawer();
              Future.delayed(const Duration(milliseconds: 1500), () {
                Scaffold.of(context).closeEndDrawer();
                TutotialCubit.of(context)
                    .goToState(TutotialCubit.openScientificKeyboardStep);
              });
            },
            child: TutorialMessage(
              tutorialStep: TutotialCubit.openDrawerStep,
              callback: (context) {
                Scaffold.of(context).openDrawer();
                Future.delayed(const Duration(milliseconds: 1500), () {
                  Scaffold.of(context).closeDrawer();
                  TutotialCubit.of(context).goToState(TutotialCubit.done);
                });
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                      bottom: 0,
                      child: SizedBox(
                        height: screenHeight * (1 - _displayHeight),
                        width: width,
                        child: SlideKeyboard(
                          foregroundWidget: BaseKeyboard(),
                          backgroundWidget: AdvancedKeyboard(
                            showFirstKeyboard: !_showSecondKeyboard,
                          ),
                          onSwitchDetected: () {
                            setState(() {
                              _showSecondKeyboard = !_showSecondKeyboard;

                              // Analytics Log
                              if (_showSecondKeyboard) {
                                FirebaseAnalytics.instance.logEvent(
                                    name: "open_2nd_scientific_keyboard");
                              }
                            });
                          },
                        ),
                      )),
                  Positioned(
                      top: 0,
                      child: Display(
                        height: screenHeight * _displayHeight,
                        expandedHeight: screenHeight,
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DisplayFontSizePopup extends StatelessWidget {
  const DisplayFontSizePopup({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<SettingsCubit, SettingsState>(builder: (context, state) {
            return Slider(
                min: 0.5,
                max: 2,
                value: state.displayFontSizeFactor,
                activeColor: Theme.of(context)
                    .extension<CalculatorTheme>()!
                    .equalsBackground,
                onChanged: (v) {
                  SettingsCubit.of(context).set(displayFontSizeFactor: v);
                });
          }),
        ],
      ),
    );
  }
}

class KeyboardFontSizePopup extends StatelessWidget {
  const KeyboardFontSizePopup({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<SettingsCubit, SettingsState>(builder: (context, state) {
            return Slider(
                min: 0.5,
                max: 2,
                value: state.keyboardFontSizeFactor,
                activeColor: Theme.of(context)
                    .extension<CalculatorTheme>()!
                    .equalsBackground,
                onChanged: (v) {
                  SettingsCubit.of(context).set(keyboardFontSizeFactor: v);
                });
          }),
        ],
      ),
    );
  }
}

class TutorialMessage extends StatelessWidget {
  final Widget child;
  final int tutorialStep;
  final Function(BuildContext) callback;
  final int? skipToStep;

  const TutorialMessage(
      {super.key,
      required this.child,
      required this.tutorialStep,
      required this.callback,
      this.skipToStep});

  @override
  Widget build(BuildContext context) {
    return BlocListener<TutotialCubit, int>(
      listenWhen: (_, current) => current == tutorialStep,
      listener: (context, state) => showDialog(
          context: context,
          builder: (dialogContext) => WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
                  title: Text(FlutterI18n.translate(
                      context, "tutorial.step$tutorialStep.title"), style: TextStyle(
                        color: Theme.of(context).extension<CalculatorTheme>()!.drawerText
                      ),),
                  content: Text(FlutterI18n.translate(
                      context, "tutorial.step$tutorialStep.message"), style: TextStyle(
                        color: Theme.of(context).extension<CalculatorTheme>()!.drawerText
                      )),
                  actionsAlignment: MainAxisAlignment.spaceBetween,
                  actions: [
                    skipToStep == null ? const SizedBox.shrink() : 
                      OutlinedButton(
                          onPressed: () {
                            TutotialCubit.of(context).skipTo(skipToStep!);
                            Navigator.pop(dialogContext);
                          },
                          style: ButtonStyle(side: MaterialStateProperty.all(BorderSide.none), foregroundColor: MaterialStateProperty.all(Colors.grey)),
                          child: Text(
                              FlutterI18n.translate(context, "tutorial.skip"))),
                    
                    OutlinedButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          await Future.delayed(const Duration(milliseconds: 200));
                          callback(context);
                        },
                        style: ButtonStyle(side: MaterialStateProperty.all(BorderSide.none)),
                        child:
                            Text(FlutterI18n.translate(context, "tutorial.ok")))
                  ],
                ),
          ),
          barrierDismissible: false),
      child: child,
    );
  }
}
