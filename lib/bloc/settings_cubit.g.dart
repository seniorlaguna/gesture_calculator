// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_SettingsState _$$_SettingsStateFromJson(Map<String, dynamic> json) =>
    _$_SettingsState(
      lightTheme: json['lightTheme'] as bool,
      displayFontSizeFactor: (json['displayFontSizeFactor'] as num).toDouble(),
      keyboardFontSizeFactor:
          (json['keyboardFontSizeFactor'] as num).toDouble(),
      fullscreen: json['fullscreen'] as bool,
      historyEnabled: json['historyEnabled'] as bool,
      scientificModeEnabled: json['scientificModeEnabled'] as bool,
      useRadians: json['useRadians'] as bool,
    );

Map<String, dynamic> _$$_SettingsStateToJson(_$_SettingsState instance) =>
    <String, dynamic>{
      'lightTheme': instance.lightTheme,
      'displayFontSizeFactor': instance.displayFontSizeFactor,
      'keyboardFontSizeFactor': instance.keyboardFontSizeFactor,
      'fullscreen': instance.fullscreen,
      'historyEnabled': instance.historyEnabled,
      'scientificModeEnabled': instance.scientificModeEnabled,
      'useRadians': instance.useRadians,
    };
