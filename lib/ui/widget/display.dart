import 'package:calculator/bloc/calculator_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:gesture_calculator/bloc/ads_cubit.dart';
import 'package:gesture_calculator/bloc/history_cubit.dart';
import 'package:gesture_calculator/bloc/settings_cubit.dart';
import 'package:gesture_calculator/bloc/tutorial_cubit.dart';
import 'package:gesture_calculator/ui/index.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Display extends StatefulWidget {
  const Display(
      {super.key, required this.height, required this.expandedHeight});

  final double height;
  final double expandedHeight;

  @override
  State<Display> createState() => _DisplayState();
}

class _DisplayState extends State<Display> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CalculatorTheme theme = Theme.of(context).extension<CalculatorTheme>()!;

    return TutorialMessage(
      tutorialStep: TutotialCubit.openHistoryStep,
      callback: _tutorialShowHistory,
      child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            double maxExtension = widget.expandedHeight - widget.height;
            double currentHeight =
                widget.height + maxExtension * _controller.value;
            double currentExtension = currentHeight - widget.height;

            return GestureDetector(
                onVerticalDragUpdate: _onKeyboardDragUpdate,
                onVerticalDragEnd: _onKeyboardDragEnd,
                child: Container(
                  decoration: BoxDecoration(
                      color: theme.buttonBackgroundBase,
                      boxShadow: _controller.value > 0
                          ? const [
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              )
                            ]
                          : null),
                  height: currentHeight,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      // Calcualtor Display
                      SizedBox(
                          height: widget.height,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: const [
                                  _BannerAd(),
                                  _CalculatorInput(),
                                  _CalculatorOutput(),
                                ],
                              ),
                            ),
                          )),

                      // History
                      (currentExtension < 124)
                          ? const Spacer()
                          : Expanded(child: _History(controller: _controller)),

                      // Clear History Button
                      if (currentExtension >= 74)
                        (_controller.value == 1)
                            ? const _HistoryClearButton().animate().fade(
                                duration: const Duration(milliseconds: 500))
                            : const SizedBox(height: 50),

                      // History Handle
                      if (currentExtension >= 24) const _DisplayHandle(),
                    ],
                  ),
                ));
          }),
    );
  }

  void _onKeyboardDragUpdate(DragUpdateDetails details) {
    // History disabled
    if (!SettingsCubit.of(context).state.historyEnabled) return;
    _controller.value +=
        details.delta.dy / (widget.expandedHeight - widget.height);
  }

  void _onKeyboardDragEnd(DragEndDetails details) {
    // History disabled
    if (!SettingsCubit.of(context).state.historyEnabled) return;

    if (_controller.value > 0.5) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _tutorialShowHistory(BuildContext context) {
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 1500), () {
      _controller.reverse();
      TutotialCubit.of(context).goToState(TutotialCubit.openDrawerStep);
    });
  }
}

class _CalculatorOutput extends StatelessWidget {
  const _CalculatorOutput({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (previous, current) =>
            previous.displayFontSizeFactor != current.displayFontSizeFactor,
        builder: (context, settingsState) {
          return BlocBuilder<CalculatorCubit, CalculatorState>(
              builder: (context, state) {
            return Text(
              state.result,
              style: TextStyle(
                  fontSize: 40.0 * settingsState.displayFontSizeFactor,
                  color: Theme.of(context)
                      .extension<CalculatorTheme>()!
                      .resultText),
            );
          });
        });
  }
}

class _CalculatorInput extends StatelessWidget {
  const _CalculatorInput({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.displayFontSizeFactor != current.displayFontSizeFactor,
      builder: (context, settingsState) {
        return TextField(
          controller: CalculatorCubit.of(context).textController,
          onTap: CalculatorCubit.of(context).textController.adjustCursor,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 50.0 * settingsState.displayFontSizeFactor,
            color:
                Theme.of(context).extension<CalculatorTheme>()!.expressionText,
          ),
          minLines: null,
          maxLines: null,
          readOnly: true,
          showCursor: true,
          decoration:
              const InputDecoration(border: InputBorder.none, hintText: "0"),
        );
      },
    );
  }
}

class _BannerAd extends StatelessWidget {
  const _BannerAd({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdsCubit, bool>(builder: (context, state) {
      if (!state) return const SizedBox();

      return Align(
        child: Container(
          alignment: Alignment.center,
          height: AdsCubit.of(context).bannerAd!.size.height.toDouble(),
          width: AdsCubit.of(context).bannerAd!.size.width.toDouble(),
          child: AdWidget(ad: AdsCubit.of(context).bannerAd!),
        ),
      );
    });
  }
}

class _HistoryClearButton extends StatelessWidget {
  const _HistoryClearButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    CalculatorTheme theme = Theme.of(context).extension<CalculatorTheme>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: OutlinedButton(
        onPressed: HistoryCubit.of(context).clearHistory,
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(theme.clearHistoryBackground),
            foregroundColor: MaterialStateProperty.all(theme.clearHistoryText),
            minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
            textStyle:
                MaterialStateProperty.all(const TextStyle(fontSize: 18))),
        child: Text(
          FlutterI18n.translate(context, "history.clear"),
        ),
      ),
    );
  }
}

class _DisplayHandle extends StatelessWidget {
  const _DisplayHandle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        height: 8,
        width: 200,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(8),
        ),
      ).animate().fadeIn(),
    );
  }
}

class _History extends StatelessWidget {
  const _History({
    super.key,
    required AnimationController controller,
  }) : _controller = controller;

  final AnimationController _controller;

  @override
  Widget build(BuildContext context) {
    CalculatorTheme theme = Theme.of(context).extension<CalculatorTheme>()!;

    return BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, historyState) {
      if (historyState.entries.isEmpty) {
        return const _HistoryEmptyMessage();
      }

      return _HistoryList(controller: _controller, theme: theme);
    });
  }
}

class _HistoryEmptyMessage extends StatelessWidget {
  const _HistoryEmptyMessage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        FlutterI18n.translate(context, "history.empty"),
        style: const TextStyle(fontSize: 20),
      ).animate().fade(duration: const Duration(milliseconds: 500)),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({
    super.key,
    required AnimationController controller,
    required this.theme,
  }) : _controller = controller;

  final AnimationController _controller;
  final CalculatorTheme theme;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, historyState) {
      return ListView.separated(
          separatorBuilder: (context, index) => const Divider(),
          itemCount: historyState.entries.length,
          itemBuilder: ((context, index) => ListTile(
                onTap: () {
                  CalculatorCubit.of(context)
                      .setExpression(historyState.entries[index]);
                  _controller.reverse();
                },
                title: Text(
                  CalculatorCubit.of(context)
                      .textController
                      .expressionFormatter
                      .format(historyState.entries[index]),
                  style: TextStyle(fontSize: 32, color: theme.expressionText),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => HistoryCubit.of(context).remove(index),
                ),
              )));
    });
  }
}
