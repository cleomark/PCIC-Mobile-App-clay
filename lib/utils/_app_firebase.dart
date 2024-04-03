import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCW_Do2U1dEmk4pWAuVWpMKUFtehscArvk',
    appId: '1:331409317731:web:c4485fc5df46f98be07d56',
    messagingSenderId: '331409317731',
    projectId: 'pcic-97692',
    authDomain: 'pcic-97692.firebaseapp.com',
    storageBucket: 'pcic-97692.appspot.com',
    databaseURL: "https://pcic-97692-default-rtdb.firebaseio.com",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCMXBz35aNPP9HnJu-lYK7guCHgdV_LX1g',
    appId: '1:331409317731:android:d7acfdf16a6842c0e07d56',
    messagingSenderId: '331409317731',
    projectId: 'pcic-97692',
    storageBucket: 'pcic-97692.appspot.com',
    databaseURL: "https://pcic-97692-default-rtdb.firebaseio.com",
  );
}
