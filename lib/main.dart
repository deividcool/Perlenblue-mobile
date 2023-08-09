import 'package:firebase_core/firebase_core.dart';
import 'package:snapta/app.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SharedPreferences.getInstance().then(
    (prefs) {
      runApp(
        Snapta(prefs),
      );
    },
  );
}
