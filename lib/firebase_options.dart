import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return FirebaseOptions(
        apiKey: 'YOUR_WEB_API_KEY',
        authDomain: 'YOUR_PROJECT.firebaseapp.com',
        projectId: 'YOUR_PROJECT_ID',
        storageBucket: 'YOUR_PROJECT.appspot.com',
        messagingSenderId: 'YOUR_SENDER_ID',
        appId: 'YOUR_WEB_APP_ID',
        measurementId: 'YOUR_MEASUREMENT_ID',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return FirebaseOptions(
          apiKey: 'YOUR_ANDROID_API_KEY',
          appId: 'YOUR_ANDROID_APP_ID',
          messagingSenderId: 'YOUR_SENDER_ID',
          projectId: 'YOUR_PROJECT_ID',
          storageBucket: 'YOUR_PROJECT.appspot.com',
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return FirebaseOptions(
          apiKey: 'YOUR_IOS_API_KEY',
          appId: 'YOUR_IOS_APP_ID',
          messagingSenderId: 'YOUR_SENDER_ID',
          projectId: 'YOUR_PROJECT_ID',
          storageBucket: 'YOUR_PROJECT.appspot.com',
          iosBundleId: 'com.your.bundleid',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}

// TODO Implement this library.
