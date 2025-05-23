// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyCVOoCLIg-2YJJOJ66wssCl20lK1OaCTgI',
    appId: '1:580164521627:web:b74c4366df2d6903e0003e',
    messagingSenderId: '580164521627',
    projectId: 'instagram-632fe',
    authDomain: 'instagram-632fe.firebaseapp.com',
    storageBucket: 'instagram-632fe.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDNLmdCXn0Q7EzBbxWBg5WpwDxPMQg3xBw',
    appId: '1:580164521627:android:27c086102c974a89e0003e',
    messagingSenderId: '580164521627',
    projectId: 'instagram-632fe',
    storageBucket: 'instagram-632fe.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA46js-w8u1APovaqbh73AWBc91cs6FM1k',
    appId: '1:580164521627:ios:36d5a8452c52794ee0003e',
    messagingSenderId: '580164521627',
    projectId: 'instagram-632fe',
    storageBucket: 'instagram-632fe.firebasestorage.app',
    iosBundleId: 'com.example.instagramClone',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA46js-w8u1APovaqbh73AWBc91cs6FM1k',
    appId: '1:580164521627:ios:36d5a8452c52794ee0003e',
    messagingSenderId: '580164521627',
    projectId: 'instagram-632fe',
    storageBucket: 'instagram-632fe.firebasestorage.app',
    iosBundleId: 'com.example.instagramClone',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCVOoCLIg-2YJJOJ66wssCl20lK1OaCTgI',
    appId: '1:580164521627:web:5aceb046dadf1a63e0003e',
    messagingSenderId: '580164521627',
    projectId: 'instagram-632fe',
    authDomain: 'instagram-632fe.firebaseapp.com',
    storageBucket: 'instagram-632fe.firebasestorage.app',
  );
}
