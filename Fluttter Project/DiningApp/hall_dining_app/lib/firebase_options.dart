import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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
    apiKey: 'your-api-key',
    appId: 'your-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    authDomain: 'your-project.firebaseapp.com',
    storageBucket: 'your-project.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-api-key',
    appId: 'your-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-project.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-api-key',
    appId: 'your-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-project.appspot.com',
    iosBundleId: 'com.example.hallDiningManagement',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'your-api-key',
    appId: 'your-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-project.appspot.com',
    iosBundleId: 'com.example.hallDiningManagement',
  );
}