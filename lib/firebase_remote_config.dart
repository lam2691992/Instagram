// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_remote_config/firebase_remote_config.dart';
// import 'package:flutter/foundation.dart';

// Future<void> initializeFirebase() async {
//   final remoteConfig = FirebaseRemoteConfig.instance;
//   await remoteConfig.setConfigSettings(RemoteConfigSettings(
//     fetchTimeout: const Duration(seconds: 10),
//     minimumFetchInterval: const Duration(hours: 1),
//   ));
//   await remoteConfig.fetchAndActivate();

//   await Firebase.initializeApp(
//     options: kIsWeb
//         ? FirebaseOptions(
//             apiKey: remoteConfig
//                 .getString('AIzaSyCVOoCLIg-2YJJOJ66wssCl20lK1OaCTgI'),
//             appId: remoteConfig
//                 .getString('1:580164521627:web:2e558bbbe1d5a1cbe0003e'),
//             messagingSenderId: remoteConfig.getString('580164521627'),
//             projectId: remoteConfig.getString('instagram-632fe'),
//             storageBucket:
//                 remoteConfig.getString('instagram-632fe.appspot.com'),
//           )
//         : null,
//   );
// }
