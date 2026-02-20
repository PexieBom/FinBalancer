// Placeholder - run: flutterfire configure
// See: https://firebase.google.com/docs/flutter/setup

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'PLACEHOLDER-RUN-FLUTTERFIRE-CONFIGURE',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'finbalancer-placeholder',
    storageBucket: 'finbalancer-placeholder.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'PLACEHOLDER-RUN-FLUTTERFIRE-CONFIGURE',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'finbalancer-placeholder',
    storageBucket: 'finbalancer-placeholder.appspot.com',
    iosBundleId: 'com.example.finbalancer',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'PLACEHOLDER-RUN-FLUTTERFIRE-CONFIGURE',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'finbalancer-placeholder',
    storageBucket: 'finbalancer-placeholder.appspot.com',
    iosBundleId: 'com.example.finbalancer',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'PLACEHOLDER-RUN-FLUTTERFIRE-CONFIGURE',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'finbalancer-placeholder',
    authDomain: 'finbalancer-placeholder.firebaseapp.com',
    storageBucket: 'finbalancer-placeholder.appspot.com',
  );
}
