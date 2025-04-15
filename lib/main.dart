  import 'dart:ui' as ui;
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/foundation.dart';
  import 'package:flutter/material.dart';
  import 'package:instagram_clone/providers/user_provider.dart';
  import 'package:instagram_clone/responsive/mobile_screen_layout.dart';
  import 'package:instagram_clone/responsive/responsive_layout_screen.dart';
  import 'package:instagram_clone/responsive/web_screen_layout.dart';
  import 'package:instagram_clone/screens/login_screen.dart';
  import 'package:instagram_clone/utils/colors.dart';
  import 'package:provider/provider.dart';
  import 'package:flutter_dotenv/flutter_dotenv.dart';  // thêm import

  void setFirebaseLanguage() {
    final String deviceLocale =
        ui.PlatformDispatcher.instance.locale.languageCode;
    const List<String> supportedLanguages = ['en', 'vi', 'fr', 'es'];

    FirebaseAuth.instance.setLanguageCode(
      supportedLanguages.contains(deviceLocale) ? deviceLocale : 'en',
    );
  }

  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    await dotenv.load();  // Load environment variables

    try {
      await Firebase.initializeApp(
        options: kIsWeb
            ? FirebaseOptions(
                apiKey: dotenv.env['API_KEY'] ?? '',
                appId: dotenv.env['APP_ID'] ?? '',
                messagingSenderId: dotenv.env['MESSAGING_SENDER_ID'] ?? '',
                projectId: dotenv.env['PROJECT_ID'] ?? '',
                storageBucket: dotenv.env['STORAGE_BUCKET'] ?? '',
              )
            : null,
      );

      setFirebaseLanguage();

      runApp(const MyApp());
    } catch (e) {
      debugPrint("Lỗi khởi tạo Firebase: $e");
    }
  }

  class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Instagram',
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: mobileBackgroundColor,
          ),
          home: const AuthWrapper(),
        ),
      );
    }
  }

  class AuthWrapper extends StatelessWidget {
    const AuthWrapper({super.key});

    @override
    Widget build(BuildContext context) {
      return StreamBuilder<User?>(  // Firebase Authentication state
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
            );
          }

          if (snapshot.hasData) {
            return const ResponsiveLayout(
              mobileScreenLayout: MobileScreenLayout(),
              webScreenLayout: WebScreenLayout(),
            );
          }

          return const LoginScreen();
        },
      );
    }
  }
