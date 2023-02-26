import 'package:calculator/bloc/calculator_cubit.dart';
import 'package:calculator/data/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:gesture_calculator/bloc/settings_cubit.dart';
import 'package:gesture_calculator/ui/index.dart';

class BaseKeyboard extends StatelessWidget {
  final keyboard = [
    [CalculatorToken.clear, CalculatorToken.clearOne, CalculatorToken.bracketAuto, CalculatorToken.opDivide],
    [CalculatorToken.num_7, CalculatorToken.num_8, CalculatorToken.num_9, CalculatorToken.opMultiply],
    [CalculatorToken.num_4, CalculatorToken.num_5, CalculatorToken.num_6, CalculatorToken.opSubtract],
    [CalculatorToken.num_1, CalculatorToken.num_2, CalculatorToken.num_3, CalculatorToken.opAdd],
    [CalculatorToken.opPercentage, CalculatorToken.num_0, CalculatorToken.dot, CalculatorToken.equals, ],
  ];

  BaseKeyboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (List<CalculatorToken> row in keyboard)
          Expanded(
            child: Row(
              children: [
                for (CalculatorToken token in row)
                  Expanded(
                    child: KeyboardKey(
                        token: token,
                        theme: Theme.of(context).extension<CalculatorTheme>()!,
                        callback: () {
                          CalculatorCubit.of(context).onTokenPressed(token);
                        },
                        textSize: 42),
                  )
              ],
            ),
          )
      ],
    );
  }
}

class AdvancedKeyboard extends StatelessWidget {
  

  final keyboard = [
    [CalculatorToken.ln, CalculatorToken.sin, CalculatorToken.cos, CalculatorToken.tan, CalculatorToken.cot],
    [CalculatorToken.log, CalculatorToken.sinh, CalculatorToken.cosh, CalculatorToken.tanh, CalculatorToken.coth],
    [CalculatorToken.squareRoot, null, null, null, null],
    [CalculatorToken.opPower, null, null, null, null],
    [CalculatorToken.factorial, null, null, null, null],
    [CalculatorToken.constPi, null, null, null, null],
    [CalculatorToken.radOrDeg, null, null, null, null],
  ];
  final keyboard2 = [
    [CalculatorToken.ePowX, CalculatorToken.asin, CalculatorToken.acos, CalculatorToken.atan, CalculatorToken.acot],
    [CalculatorToken.tenPowX, CalculatorToken.asinh, CalculatorToken.acosh, CalculatorToken.atanh, CalculatorToken.acoth],
    [CalculatorToken.squared, null, null, null, null],
    [CalculatorToken.opPower, null, null, null, null],
    [CalculatorToken.abs, null, null, null, null],
    [CalculatorToken.constE, null, null, null, null],
    [CalculatorToken.radOrDeg, null, null, null, null],
  ];

  final bool showFirstKeyboard;

  AdvancedKeyboard({super.key, required this.showFirstKeyboard});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (List<CalculatorToken?> row in (showFirstKeyboard ? keyboard : keyboard2))
          Expanded(
            child: Row(
              children: [
                for (CalculatorToken? token in row)
                  token == null
                      ? const Spacer()
                      : Expanded(
                          child: KeyboardKey(
                            token: token,
                            callback: () {
                              if (token == CalculatorToken.radOrDeg) {
                                SettingsCubit.of(context).set(useRadians: !SettingsCubit.of(context).state.useRadians);
                              }
                              CalculatorCubit.of(context).onTokenPressed(token);
                            },
                            textSize: 30,
                            theme:
                                Theme.of(context).extension<CalculatorTheme>()!,
                                extendedBackground: true,
                          ),
                        )
              ],
            ),
          )
      ],
    );
  }
}

class KeyboardKey extends StatelessWidget {
  final List<CalculatorToken> highlightedOperators = 
  [
    CalculatorToken.opAdd,
    CalculatorToken.opSubtract,
    CalculatorToken.opDivide,
    CalculatorToken.opMultiply,
    CalculatorToken.bracketAuto,
    CalculatorToken.clearOne,
    CalculatorToken.opPercentage,
  ];

  final CalculatorToken token;
  final Function() callback;
  final CalculatorTheme theme;
  final double textSize;
  final bool extendedBackground;

  KeyboardKey(
      {super.key,
      required this.token,
      required this.callback,
      required this.theme,
      required this.textSize,
      this.extendedBackground = false});

  Color get textColor {
    if (highlightedOperators.contains(token)) {
      return theme.operatorText;
    } else if (token == CalculatorToken.clear) {
      return theme.clearAllText;
    } else if (token == CalculatorToken.equals) {
      return theme.equalsColor;
    }
    return theme.defaultText;
  }

  Color get backgroundColor {
    if (token == CalculatorToken.equals) {
      return theme.equalsBackground;
    }
    return extendedBackground ? theme.buttonBackgroundExtended : theme.buttonBackgroundBase;
    
  }

  Color? get overlayColor {
    if (token == CalculatorToken.equals) {
      return theme.equalsOverlay;
    } else if (token == CalculatorToken.clear) {
      return theme.clearAllOverlay;
    }
    return null;
  }

  Widget getText(BuildContext context) {

    return FittedBox(
      child: BlocBuilder<SettingsCubit, SettingsState>(builder: (context, settingsState) {
        if (token == CalculatorToken.clearOne) {
        return Icon(Icons.backspace_outlined, color: textColor, size: 38 * settingsState.keyboardFontSizeFactor,);
      } else if (token == CalculatorToken.radOrDeg) {
        return BlocBuilder<CalculatorCubit, CalculatorState>(builder: (context, state) {
          return Text(
            key: ValueKey(token),
            state.useRadians ? "RAD" : "DEG",
            style: TextStyle(fontSize: textSize * settingsState.keyboardFontSizeFactor, color: textColor),
          );
        });
      }
    
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Text(
          key: ValueKey(token),
          FlutterI18n.translate(context, token.name),
          style: TextStyle(fontSize: textSize * settingsState.keyboardFontSizeFactor, color: textColor),
        ),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
      );
      },),
    );

    
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.zero),
            backgroundColor: MaterialStateProperty.all(backgroundColor),
            overlayColor: MaterialStateProperty.all(overlayColor),
            side: MaterialStateProperty.all(BorderSide(
                color: Theme.of(context)
                    .extension<CalculatorTheme>()!
                    .spacingColor,
                width: 0.5)),
            shape: MaterialStateProperty.all(const RoundedRectangleBorder())),
        onPressed: callback,
        child: Center(
          child: getText(context),
        ));
  }
}
