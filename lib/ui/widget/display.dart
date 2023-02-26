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
    return BlocConsumer<SettingsCubit, SettingsState>(
        listener: (context, state) => _controller.reverse(),
        listenWhen: (_, current) => !current.historyEnabled,
        buildWhen: (previous, current) =>
            previous.historyEnabled != current.historyEnabled,
        builder: (context, state) {
          return TutorialMessage(
            tutorialStep: TutotialCubit.openHistoryStep,
            callback: (_) async {
              _controller.forward();
              Future.delayed(const Duration(milliseconds: 1500), () {
                _controller.reverse();
                TutotialCubit.of(context).goToState(TutotialCubit.openDrawerStep);
              });
              
            },
            child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  double maxExtension = widget.expandedHeight - widget.height;
                  double currentHeight =
                      widget.height + maxExtension * _controller.value;
                  double currentExtension = currentHeight - widget.height;

                  return GestureDetector(
                      onVerticalDragUpdate: !state.historyEnabled
                          ? null
                          : (details) => _controller.value += details.delta.dy /
                              (widget.expandedHeight - widget.height),
                      onVerticalDragEnd: !state.historyEnabled
                          ? null
                          : (_) {
                              if (_controller.value > 0.5) {
                                _controller.forward();
                              } else {
                                _controller.reverse();
                              }
                            },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context)
                                .extension<CalculatorTheme>()!
                                .buttonBackgroundBase,
                            boxShadow: _controller.value > 0
                                ? const [
                                    BoxShadow(
                                        color: Colors.grey,
                                        offset: Offset(0, 2),
                                        blurRadius: 4)
                                  ]
                                : null),
                        height: currentHeight,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            SizedBox(
                                height: widget.height,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SingleChildScrollView(
                                    child: BlocBuilder<SettingsCubit,
                                            SettingsState>(
                                        buildWhen: (previous, current) =>
                                            previous.displayFontSizeFactor !=
                                            current.displayFontSizeFactor,
                                        builder: (context, settingsState) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              if (true)
                                                BlocBuilder<AdsCubit, bool>(
                                                    builder: (context, state) {
                                                  if (!state) return SizedBox();

                                                  return Align(
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      height:
                                                          AdsCubit.of(context)
                                                              .bannerAd!
                                                              .size
                                                              .height
                                                              .toDouble(),
                                                      width:
                                                          AdsCubit.of(context)
                                                              .bannerAd!
                                                              .size
                                                              .width
                                                              .toDouble(),
                                                      child: AdWidget(
                                                          ad: AdsCubit.of(
                                                                  context)
                                                              .bannerAd!),
                                                    ),
                                                  );
                                                }),
                                              TextField(
                                                controller:
                                                    CalculatorCubit.of(context)
                                                        .textController,
                                                onTap:
                                                    CalculatorCubit.of(context)
                                                        .textController
                                                        .adjustCursor,
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  fontSize: 50.0 *
                                                      settingsState
                                                          .displayFontSizeFactor,
                                                  color: Theme.of(context)
                                                      .extension<
                                                          CalculatorTheme>()!
                                                      .expressionText,
                                                ),
                                                minLines: null,
                                                maxLines: null,
                                                readOnly: true,
                                                showCursor: true,
                                                decoration:
                                                    const InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        hintText: "0"),
                                              ),
                                              BlocBuilder<CalculatorCubit,
                                                      CalculatorState>(
                                                  builder: (context, state) {
                                                return Text(
                                                  state.result,
                                                  style: TextStyle(
                                                      fontSize: 40.0 *
                                                          settingsState
                                                              .displayFontSizeFactor,
                                                      color: Theme.of(context)
                                                          .extension<
                                                              CalculatorTheme>()!
                                                          .resultText),
                                                );
                                              }),
                                            ],
                                          );
                                        }),
                                  ),
                                )),
                            (currentExtension < 124)
                                ? Spacer()
                                : Expanded(child:
                                    BlocBuilder<HistoryCubit, HistoryState>(
                                        builder: (context, historyState) {
                                    if (historyState.entries.isEmpty)
                                      return Center(
                                        child: Text(
                                          FlutterI18n.translate(
                                              context, "history.empty"),
                                          style: TextStyle(fontSize: 20),
                                        ).animate().fade(
                                            duration:
                                                Duration(milliseconds: 500)),
                                      );

                                    return ListView.separated(
                                        separatorBuilder: (context, index) =>
                                            Divider(),
                                        itemCount: historyState.entries.length,
                                        itemBuilder: ((context, index) =>
                                            ListTile(
                                              onTap: () {
                                                CalculatorCubit.of(context)
                                                    .setExpression(historyState
                                                        .entries[index]);
                                                _controller.reverse();
                                              },
                                              title: Text(
                                                CalculatorCubit.of(context)
                                                    .textController
                                                    .expressionFormatter
                                                    .format(historyState
                                                        .entries[index]),
                                                style: TextStyle(
                                                    fontSize: 32,
                                                    color: Theme.of(context)
                                                        .extension<
                                                            CalculatorTheme>()!
                                                        .expressionText),
                                              ),
                                              trailing: IconButton(
                                                icon: Icon(Icons.delete),
                                                onPressed: () {
                                                  HistoryCubit.of(context)
                                                      .remove(index);
                                                },
                                              ),
                                            )));
                                  })),
                            if (currentExtension >= 74)
                              (_controller.value == 1)
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24),
                                      child: TextButton(
                                        onPressed: () {
                                          HistoryCubit.of(context).clearHistory();
                                        },
                                        style: TextButton.styleFrom(
                                            backgroundColor: Theme.of(context)
                                                .extension<CalculatorTheme>()!
                                                .clearHistoryBackground,
                                            primary: Theme.of(context)
                                                .extension<CalculatorTheme>()!
                                                .clearHistoryText,
                                            minimumSize:
                                                const Size.fromHeight(50),
                                            textStyle:
                                                const TextStyle(fontSize: 18)),
                                        child: Text(FlutterI18n.translate(
                                            context, "history.clear")),
                                      ),
                                    ).animate().fade(
                                      duration: Duration(milliseconds: 500))
                                  : SizedBox(height: 50),
                            if (currentExtension >= 24)
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Container(
                                  height: 8,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ).animate().fadeIn(),
                              ),
                          ],
                        ),
                      ));
                }),
          );
        });
  }
}
