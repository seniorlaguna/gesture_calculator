import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:gesture_calculator/bloc/settings_cubit.dart';
import 'package:gesture_calculator/bloc/tutorial_cubit.dart';
import 'package:gesture_calculator/ui/index.dart';

class SlideKeyboard extends StatefulWidget {
  final Widget foregroundWidget;
  final Widget backgroundWidget;
  final Function onSwitchDetected;

  const SlideKeyboard(
      {super.key,
      required this.onSwitchDetected,
      required this.foregroundWidget,
      required this.backgroundWidget});

  @override
  State<SlideKeyboard> createState() => _SlideKeyboardState();
}

class _SlideKeyboardState extends State<SlideKeyboard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 300));
  double _animationStartValue = 0;
  bool keyboardWasSliding = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TutorialMessage(
      tutorialStep: TutotialCubit.openScientificKeyboardStep,
      callback: (context) async {
        _controller.forward();
        TutotialCubit.of(context).goToState(TutotialCubit.switchScientificKeyboardStep);

      },
      child: BlocConsumer<SettingsCubit, SettingsState>(
        listener: (context, state) {
          _controller.reverse();
        },
        listenWhen: (previous, current) => !current.scientificModeEnabled,
        builder: (context, state) {
          return LayoutBuilder(
          builder: (context, constraints) => GestureDetector(
            onHorizontalDragStart: !state.scientificModeEnabled ? null : (_) {
              _animationStartValue = _controller.value;
            },
            onHorizontalDragUpdate: !state.scientificModeEnabled ? null : (details) {
              _controller.value += details.delta.dx / (constraints.maxWidth * 0.4);
            
              if (!keyboardWasSliding && _controller.value < 1) {
                keyboardWasSliding = true;
              }
            },
            onHorizontalDragEnd: !state.scientificModeEnabled ? null : (details) {
              if (!keyboardWasSliding && _animationStartValue == 1 &&
                  details.velocity.pixelsPerSecond.dx > 0) {
                widget.onSwitchDetected();
              }
            
              if (_controller.value > 0.5) {
                _controller.forward();
      
                // Analytics Log
                FirebaseAnalytics.instance.logEvent(name: "open_scientific_keyboard");
                
              } else {
                _controller.reverse();
              }
              keyboardWasSliding = false;
            },
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                widget.backgroundWidget,
                AnimatedBuilder(
                    animation: _controller,
                    child: widget.foregroundWidget,
                    builder: (context, widget) {
                      return SizedBox(
                        width: constraints.maxWidth * (1 - 0.2 * _controller.value),
                        height: constraints.maxHeight * (1 - 2 / 7 * _controller.value),
                        child: widget,
                      );
                    })
              ],
            ),
          ),
        );
        },
      ),
    );
  }
}
