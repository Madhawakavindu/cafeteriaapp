import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class FirebaseInitialization {
  static Future<void> initialize() async {
    if (Firebase.apps.isNotEmpty) {
      Firebase.app();
      return;
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
