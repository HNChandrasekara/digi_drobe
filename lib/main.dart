import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'services/auth_service.dart';
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  bool firebaseInitialized = false;
  try {
    debugPrint('Firebase: Initializing...');
    await Firebase.initializeApp().timeout(const Duration(seconds: 3));
    AuthService.markInitialized();
    firebaseInitialized = true;
    debugPrint('Firebase: Success');
  } catch (e) {
    debugPrint('Firebase: Failed/Timeout (using fallback): $e');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Caught Flutter error: ${details.exception}');
  };

  runApp(MyApp(firebaseInitialized: firebaseInitialized));
}

class MyApp extends StatelessWidget {
  final bool firebaseInitialized;
  const MyApp({super.key, required this.firebaseInitialized});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digi Drobe',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryMaroon,
          surface: AppColors.surfaceLight,
        ),
        scaffoldBackgroundColor: AppColors.backgroundLight,
      ),
      builder: (context, child) {
        return Material(
          color: AppColors.backgroundLight,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
      home: !firebaseInitialized
          ? const HomeScreen() // Development fallback
          : StreamBuilder<User?>(
              stream: AuthService().authStateChanges,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  User? user = snapshot.data;
                  if (user == null) {
                    return const LoginScreen();
                  }
                  return const HomeScreen();
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
    );
  }
}
