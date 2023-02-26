import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:fullscreen/fullscreen.dart';
import 'package:gesture_calculator/ui/index.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'settings_cubit.freezed.dart';
part 'settings_cubit.g.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState(
      {required bool lightTheme,
      required double displayFontSizeFactor,
      required double keyboardFontSizeFactor,
      required bool fullscreen,
      required bool historyEnabled,
      required bool scientificModeEnabled,
      required bool useRadians
      }) = _SettingsState;

  factory SettingsState.fromJson(Map<String, Object?> json) =>
      _$SettingsStateFromJson(json);
}

class SettingsCubit extends HydratedCubit<SettingsState>  {
  static const SettingsState defaultState = SettingsState(
      lightTheme: true,
      displayFontSizeFactor: 1.0,
      keyboardFontSizeFactor: 1.0,
      fullscreen: false,
      historyEnabled: true,
      scientificModeEnabled: true,
      useRadians: true
      );

  static SettingsCubit of(BuildContext context) =>
      BlocProvider.of<SettingsCubit>(context);

  SettingsCubit(super.initialState);

  Future<void> handleFullscreenSettings() async {
    state.fullscreen ? FullScreen.enterFullScreen(FullScreenMode.EMERSIVE_STICKY) : FullScreen.exitFullScreen();
  }

  Future<void> set(
      {
        double? displayFontSizeFactor, double? keyboardFontSizeFactor,
        bool? lightTheme,
        bool? fullscreen,
      bool? scientificModeEnabled,
      bool? historyEnabled,
      bool? useRadians}) async {

    emit(state.copyWith(
      displayFontSizeFactor: displayFontSizeFactor ?? state.displayFontSizeFactor,
      keyboardFontSizeFactor: keyboardFontSizeFactor ?? state.keyboardFontSizeFactor,
      lightTheme: lightTheme ?? state.lightTheme,
        fullscreen: fullscreen ?? state.fullscreen,
        scientificModeEnabled:
            scientificModeEnabled ?? state.scientificModeEnabled,
        historyEnabled: historyEnabled ?? state.historyEnabled,
        useRadians: useRadians ?? state.useRadians));
  }
  
  @override
  SettingsState? fromJson(Map<String, dynamic> json) {
    return SettingsState.fromJson(json);
  }
  
  @override
  Map<String, dynamic>? toJson(SettingsState state) {
    return state.toJson();
  }
}
