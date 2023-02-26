import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:fullscreen/fullscreen.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bloc/settings_cubit.dart';
import '../index.dart';

class PromoDrawer extends StatelessWidget {
  const PromoDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    CalculatorTheme theme = Theme.of(context).extension<CalculatorTheme>()!;

    return Drawer(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 0),
            child: ClipOval(
                child: Image.asset(
              "assets/senior_laguna.webp",
              height: 124,
              width: 124,
            )),
          ),
          Text(
            "Senior Laguna",
            style: TextStyle(fontSize: 24, color: theme.drawerText),
          ),
          Text(
            "Apps made with 💜",
            style: TextStyle(color: theme.resultText),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(
              height: 1,
              endIndent: 64,
              indent: 64,
            ),
          ),
          ListTile(
            textColor: theme.drawerText,
            title: Text(
              FlutterI18n.translate(context, "drawer.like"),
            ),
            leading: const Icon(Icons.favorite),
            onTap: likeApp,
          ),
          ListTile(
            textColor: theme.drawerText,
            title: Text(FlutterI18n.translate(context, "drawer.more_apps")),
            leading: const Icon(Icons.apps),
            onTap: () => openUrl(
                "https://play.google.com/store/apps/developer?id=Senior+Laguna"),
          ),
          ListTile(
            textColor: theme.drawerText,
            title: Text(FlutterI18n.translate(context, "drawer.get_premium")),
            leading: const Icon(Icons.workspace_premium),
            onTap: () => openUrl(
                "https://play.google.com/store/apps/details?id=org.seniorlaguna.gcalculator.pro"),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Divider(
              height: 1,
              endIndent: 64,
              indent: 64,
            ),
          ),
          ListTile(
            textColor: theme.drawerText,
            title: Text(FlutterI18n.translate(context, "drawer.contact")),
            leading: const Icon(Icons.person),
            onTap: () =>
                openUrl(FlutterI18n.translate(context, "drawer.url.contact")),
          ),
          ListTile(
            textColor: theme.drawerText,
            title: Text(FlutterI18n.translate(context, "drawer.terms")),
            leading: const Icon(Icons.casino),
            onTap: () =>
                openUrl(FlutterI18n.translate(context, "drawer.url.terms")),
          ),
          ListTile(
            textColor: theme.drawerText,
            title: Text(FlutterI18n.translate(context, "drawer.privacy")),
            leading: const Icon(Icons.lock),
            onTap: () =>
                openUrl(FlutterI18n.translate(context, "drawer.url.privacy")),
          ),
          ListTile(
            textColor: theme.drawerText,
            title: Text(FlutterI18n.translate(context, "drawer.about")),
            leading: const Icon(Icons.people),
            onTap: () =>
                showAboutDialog(context: context, applicationVersion: "1.1.0"),
          ),
        ],
      ),
    );
  }

  Future<void> likeApp() async {
    if (await InAppReview.instance.isAvailable()) {
      InAppReview.instance.requestReview();
    } else {
      openUrl(
          "https://play.google.com/store/apps/details?id=org.seniorlaguna.gcalculator");
    }
  }

  Future<void> openUrl(String url) async {
    try {
      launchUrl(Uri.parse(url));
    } catch (e) {}
  }
}

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    CalculatorTheme theme = Theme.of(context).extension<CalculatorTheme>()!;

    return Drawer(
      child:
          BlocBuilder<SettingsCubit, SettingsState>(builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    FlutterI18n.translate(context, "drawer.settings"),
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    FlutterI18n.translate(context, "drawer.settings_subtitle"),
                    style: TextStyle(color: theme.resultText),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
              endIndent: 64,
              indent: 64,
            ),
            SwitchListTile(
                title: Text(
                  FlutterI18n.translate(context, "drawer.light_theme"),
                  style: TextStyle(color: theme.drawerText),
                ),
                value: state.lightTheme,
                onChanged: (v) {
                  SettingsCubit.of(context).set(lightTheme: v);
                }),
            ListTile(
              textColor: theme.drawerText,
              title: Text(
                  FlutterI18n.translate(context, "drawer.display_font_size")),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                    context: context,
                    builder: (context) => const DisplayFontSizePopup());
              },
            ),
            ListTile(
              textColor: theme.drawerText,
              title: Text(
                  FlutterI18n.translate(context, "drawer.keyboard_font_size")),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                    context: context,
                    builder: (context) => const KeyboardFontSizePopup());
              },
            ),
            SwitchListTile(
                title: Text(FlutterI18n.translate(context, "drawer.fullscreen"),
                    style: TextStyle(color: theme.drawerText)),
                value: state.fullscreen,
                onChanged: (_) => _onFullscreenSettingsChange(context)),
            const Divider(
              height: 1,
              endIndent: 64,
              indent: 64,
            ),
            SwitchListTile(
                title: Text(
                  FlutterI18n.translate(context, "drawer.scientific_mode"),
                  style: TextStyle(
                    color: theme.drawerText,
                  ),
                ),
                value: state.scientificModeEnabled,
                onChanged: (v) =>
                    SettingsCubit.of(context).set(scientificModeEnabled: v)),
            SwitchListTile(
                title: Text(FlutterI18n.translate(context, "drawer.history"),
                    style: TextStyle(color: theme.drawerText)),
                value: state.historyEnabled,
                onChanged: (v) =>
                    SettingsCubit.of(context).set(historyEnabled: v)),
          ],
        );
      }),
    );
  }

  void _onFullscreenSettingsChange(BuildContext context) {
    if (SettingsCubit.of(context).state.fullscreen) {
      FullScreen.exitFullScreen();
      SettingsCubit.of(context).set(fullscreen: false);
    } else {
      FullScreen.enterFullScreen(FullScreenMode.EMERSIVE_STICKY);
      SettingsCubit.of(context).set(fullscreen: true);
    }
  }
}
