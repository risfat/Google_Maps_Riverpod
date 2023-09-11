// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAcK-pV2clcgPAYSkq4eW-l_tKtkRtMwVw',
    appId: '1:269887907542:web:2004da15a0de64a1588b77',
    messagingSenderId: '269887907542',
    projectId: 'maps-with-riverpod',
    authDomain: 'maps-with-riverpod.firebaseapp.com',
    storageBucket: 'maps-with-riverpod.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB8Z0BGZ09DAY4aJB873jzfy0VHaQzo35s',
    appId: '1:269887907542:android:53a203c51dcda9f1588b77',
    messagingSenderId: '269887907542',
    projectId: 'maps-with-riverpod',
    storageBucket: 'maps-with-riverpod.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC3FcO-Frw9S77OUlA_0NElbkdMezxSzM0',
    appId: '1:269887907542:ios:d92cdcbfe4ac9970588b77',
    messagingSenderId: '269887907542',
    projectId: 'maps-with-riverpod',
    storageBucket: 'maps-with-riverpod.appspot.com',
    iosBundleId: 'dev.risfat.googleMapsRiverpod',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC3FcO-Frw9S77OUlA_0NElbkdMezxSzM0',
    appId: '1:269887907542:ios:459bd48c40a79bf2588b77',
    messagingSenderId: '269887907542',
    projectId: 'maps-with-riverpod',
    storageBucket: 'maps-with-riverpod.appspot.com',
    iosBundleId: 'dev.risfat.googleMapsRiverpod.RunnerTests',
  );
}
