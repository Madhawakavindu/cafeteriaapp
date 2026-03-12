import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';

class FirebaseInitialization {
  static Future<void> initialize() async {
    if (kIsWeb) {
      if (Firebase.apps.isNotEmpty) {
        Firebase.app();
        return;
      }

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Web requires a reCAPTCHA v3 site key before App Check can be enabled.
      return;
    }

    try {
      Firebase.app();
    } on FirebaseException {
      await Firebase.initializeApp();
    }

    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider: kDebugMode
            ? AndroidProvider.debug
            : AndroidProvider.playIntegrity,
        appleProvider: kDebugMode
            ? AppleProvider.debug
            : AppleProvider.deviceCheck,
      );
    } on MissingPluginException {
      // Plugin may be unavailable until a full restart after dependency changes.
    }
  }
}
