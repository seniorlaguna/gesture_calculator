import 'package:flutter/material.dart';

class CalculatorTheme extends ThemeExtension<CalculatorTheme> {
  final Color equalsBackground;
  final Color equalsColor;
  final Color equalsOverlay;
  final Color clearAllText;
  final Color clearAllOverlay;
  final Color spacingColor;
  final Color defaultText;
  final Color buttonBackgroundExtended;
  final Color buttonBackgroundBase;
  final Color operatorText;
  final Color operatorBackground;
  final Color screenAndHistory;
  final Color removeHistoryItemAction;
  final Color expressionText;
  final Color resultText;
  final Color clearHistoryText;
  final Color clearHistoryBackground;
  final Color historyHandle;
  final Color historyItem;
  final Color drawerText;

  CalculatorTheme(
      this.equalsBackground,
      this.equalsColor,
      this.equalsOverlay,
      this.clearAllText,
      this.clearAllOverlay,
      this.spacingColor,
      this.defaultText,
      this.buttonBackgroundExtended,
      this.buttonBackgroundBase,
      this.operatorText,
      this.operatorBackground,
      this.screenAndHistory,
      this.removeHistoryItemAction,
      this.expressionText,
      this.resultText,
      this.clearHistoryText,
      this.clearHistoryBackground,
      this.historyHandle,
      this.historyItem,
      this.drawerText);

  @override
  ThemeExtension<CalculatorTheme> copyWith(
      {Color? equalsBackground,
      Color? equalsColor,
      Color? equalsOverlay,
      Color? clearAllText,
      Color? clearAllOverlay,
      Color? spacingColor,
      Color? defaultText,
      Color? buttonBackgroundExtended,
      Color? buttonBackgroundBase,
      Color? operatorText,
      Color? operatorBackground,
      Color? screenAndHistory,
      Color? removeHistoryItemAction,
      Color? expressionText,
      Color? resultText,
      Color? clearHistoryText,
      Color? clearHistoryBackground,
      Color? historyHandle,
      Color? historyItem,
      Color? drawerText}) {
    return CalculatorTheme(
        equalsBackground ?? this.equalsBackground,
        equalsColor ?? this.equalsColor,
        equalsOverlay ?? this.equalsOverlay,
        clearAllText ?? this.clearAllOverlay,
        clearAllOverlay ?? this.clearAllOverlay,
        spacingColor ?? this.spacingColor,
        defaultText ?? this.defaultText,
        buttonBackgroundExtended ?? this.buttonBackgroundExtended,
        buttonBackgroundBase ?? this.buttonBackgroundBase,
        operatorText ?? this.operatorText,
        operatorBackground ?? this.operatorBackground,
        screenAndHistory ?? this.screenAndHistory,
        removeHistoryItemAction ?? this.removeHistoryItemAction,
        expressionText ?? this.expressionText,
        resultText ?? this.resultText,
        clearHistoryText ?? this.clearHistoryText,
        clearHistoryBackground ?? this.clearHistoryBackground,
        historyHandle ?? this.historyHandle,
        historyItem ?? this.historyItem,
        drawerText ?? this.drawerText);
  }

  @override
  ThemeExtension<CalculatorTheme> lerp(
      ThemeExtension<CalculatorTheme>? other, double t) {
    return this;
  }
}

final lightTheme = CalculatorTheme(
    const Color(0xFF4047F0),
    Colors.white,
    Colors.white.withOpacity(0.3),
    const Color(0xFFDE5050),
    Colors.redAccent.withOpacity(0.3),
    const Color(0xFFC4C4C4),
    Colors.black54,
    const Color(0xffF6F6F6),
    Colors.white,
    const Color(0xFF4C79EB),
    Colors.white,
    Colors.white,
    Colors.red,
    Colors.black,
    Colors.grey,
    Colors.white,
    const Color(0xFF4047F0),
    Colors.grey,
    Colors.black,
    Colors.black);

final darkTheme = CalculatorTheme(
    const Color(0xFF4047F0),
    Colors.white,
    Colors.white.withOpacity(0.3),
    const Color(0xFFDE5050),
    Colors.redAccent.withOpacity(0.3),
    Colors.white10,
    Colors.white,
    Colors.black12,
    const Color.fromARGB(255, 55, 55, 55),
    const Color(0xFF4C79EB),
    const Color.fromARGB(255, 55, 55, 55),
    const Color.fromARGB(255, 55, 55, 55),
    Colors.red,
    Colors.white,
    Colors.grey,
    Colors.white,
    const Color(0xFF4047F0),
    Colors.grey,
    Colors.white,
    Colors.white);
