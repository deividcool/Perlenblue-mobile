import 'dart:io';
import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:snapta/global/global.dart';
import 'package:snapta/layouts/splashscreen.dart';
import 'package:snapta/layouts/tabbar/new_tabbar.dart';
import 'package:snapta/route_generator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapta/shared_preferences/preferencesKey.dart';

class AppThemes {
  static const int Light = 0;
  static const int Dark = 1;

  static String toStr(int themeId) {
    switch (themeId) {
      case Light:
        return "Light";
      case Dark:
        return "Dark";

      default:
        return "Unknown";
    }
  }
}

class Snapta extends StatelessWidget {
  final SharedPreferences prefs;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Snapta(this.prefs);
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    setnotification();
    final themeCollection = ThemeCollection(themes: {
      AppThemes.Light: ThemeData(
        fontFamily: 'Lato',
        // primaryColor: appColor,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColorLight: appColorBlack,
      ),
      AppThemes.Dark: ThemeData(
        fontFamily: 'Lato',
        // primaryColor: appColorBlack,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColorLight: appColorWhite,
      ),
    });
    return DynamicTheme(
        themeCollection: themeCollection,
        defaultThemeId: AppThemes.Light,
        builder: (context, theme) {
          return MaterialApp(
            theme: theme,
            // theme: ThemeData(
            //     accentColor: appColorOrange,
            //     primaryColor: appColor,
            //     fontFamily: 'Lato',
            //     colorScheme:
            //         ColorScheme.fromSwatch().copyWith(secondary: appColor)),
            debugShowCheckedModeBanner: false,
            home: _handleCurrentScreen(prefs),
            onGenerateRoute: RouteGenerator.generateRoute,
          );
        });
  }

  Widget _handleCurrentScreen(SharedPreferences prefs) {
    String data = prefs.getString(SharedPreferencesKey.LOGGED_IN_USERRDATA)!;
    preferences = prefs;
    if (data == null) {
      return SplashScreen();
    } else {
      return BottomTabbar(currentTab: 0);
    }
  }

  setnotification() async {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    if (Platform.isIOS) {
      firebaseMessaging.requestPermission(
        sound: true,
        alert: true,
        badge: true,
      );
    } else {}
  }
}
