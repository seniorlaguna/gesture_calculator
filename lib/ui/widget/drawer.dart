import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:fullscreen/fullscreen.dart';
import 'package:gesture_calculator/bloc/tutorial_cubit.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../bloc/settings_cubit.dart';
import '../index.dart';

class PromoDrawer extends StatelessWidget {
  const PromoDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
            style: TextStyle(
                fontSize: 24,
                color:
                    Theme.of(context).extension<CalculatorTheme>()!.drawerText),
          ),
          Text(
            "Apps made with 💜",
            style: TextStyle(
                color:
                    Theme.of(context).extension<CalculatorTheme>()!.resultText),
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
            textColor:
                Theme.of(context).extension<CalculatorTheme>()!.drawerText,
            title: Text(
              FlutterI18n.translate(context, "drawer.like"),
            ),
            leading: const Icon(Icons.favorite),
            onTap: likeApp,
          ),
          ListTile(
            textColor:
                Theme.of(context).extension<CalculatorTheme>()!.drawerText,
            title: Text(FlutterI18n.translate(context, "drawer.more_apps")),
            leading: const Icon(Icons.apps),
            onTap: () => openUrl(
                "https://play.google.com/store/apps/developer?id=Senior+Laguna"),
          ),
          ListTile(
            textColor:
                Theme.of(context).extension<CalculatorTheme>()!.drawerText,
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
            textColor:
                Theme.of(context).extension<CalculatorTheme>()!.drawerText,
            title: Text(FlutterI18n.translate(context, "drawer.contact")),
            leading: const Icon(Icons.person),
            onTap: () =>
                openUrl(FlutterI18n.translate(context, "drawer.url.contact")),
          ),
          ListTile(
            textColor:
                Theme.of(context).extension<CalculatorTheme>()!.drawerText,
            title: Text(FlutterI18n.translate(context, "drawer.terms")),
            leading: const Icon(Icons.casino),
            onTap: () =>
                openUrl(FlutterI18n.translate(context, "drawer.url.terms")),
          ),
          ListTile(
            textColor:
                Theme.of(context).extension<CalculatorTheme>()!.drawerText,
            title: Text(FlutterI18n.translate(context, "drawer.privacy")),
            leading: const Icon(Icons.lock),
            onTap: () =>
                openUrl(FlutterI18n.translate(context, "drawer.url.privacy")),
          ),
          ListTile(
            textColor:
                Theme.of(context).extension<CalculatorTheme>()!.drawerText,
            title: Text(FlutterI18n.translate(context, "drawer.about")),
            leading: const Icon(Icons.people),
            onTap: () {
              showAboutDialog(context: context, applicationVersion: "1.1.0");
            },
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
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    FlutterI18n.translate(context, "drawer.settings_subtitle"),
                    style: TextStyle(
                        color: Theme.of(context)
                            .extension<CalculatorTheme>()!
                            .resultText),
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
                  style: TextStyle(
                      color: Theme.of(context)
                          .extension<CalculatorTheme>()!
                          .drawerText),
                ),
                value: state.lightTheme,
                onChanged: (v) {
                  SettingsCubit.of(context).set(lightTheme: v);
                }),
            ListTile(
              textColor:
                  Theme.of(context).extension<CalculatorTheme>()!.drawerText,
              title: Text(
                  FlutterI18n.translate(context, "drawer.display_font_size")),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                    context: context,
                    builder: (context) => DisplayFontSizePopup());
              },
            ),
            ListTile(
              textColor:
                  Theme.of(context).extension<CalculatorTheme>()!.drawerText,
              title: Text(
                  FlutterI18n.translate(context, "drawer.keyboard_font_size")),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                    context: context,
                    builder: (context) => KeyboardFontSizePopup());
              },
            ),
            SwitchListTile(
                title: Text(FlutterI18n.translate(context, "drawer.fullscreen"),
                    style: TextStyle(
                        color: Theme.of(context)
                            .extension<CalculatorTheme>()!
                            .drawerText)),
                value: state.fullscreen,
                onChanged: (v) {
                  state.fullscreen
                      ? FullScreen.exitFullScreen()
                      : FullScreen.enterFullScreen(
                          FullScreenMode.EMERSIVE_STICKY);
                  SettingsCubit.of(context).set(fullscreen: !state.fullscreen);
                }),
            const Divider(
              height: 1,
              endIndent: 64,
              indent: 64,
            ),
            SwitchListTile(
                title: Text(
                    FlutterI18n.translate(context, "drawer.scientific_mode"),
                    style: TextStyle(
                        color: Theme.of(context)
                            .extension<CalculatorTheme>()!
                            .drawerText)),
                value: state.scientificModeEnabled,
                onChanged: (v) {
                  SettingsCubit.of(context).set(scientificModeEnabled: v);
                }),
            SwitchListTile(
                title: Text(FlutterI18n.translate(context, "drawer.history"),
                    style: TextStyle(
                        color: Theme.of(context)
                            .extension<CalculatorTheme>()!
                            .drawerText)),
                value: state.historyEnabled,
                onChanged: (v) {
                  SettingsCubit.of(context).set(historyEnabled: v);
                }),
          ],
        );
      }),
    );
  }
}
