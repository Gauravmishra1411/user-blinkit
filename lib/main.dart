// Vercel Deployment Trigger: 2026-04-18
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'src/views/login_page.dart';
import 'src/views/address_page.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Load .env file
    await dotenv.load(fileName: ".env");
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
        authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '',
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '',
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
        appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
        measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID'] ?? '',
      ),
    );

    runApp(const BlinkiteApp());
  } catch (e) {
    debugPrint('Initialization error: $e');
    // Still run the app so it doesn't just show a white screen if possible
    runApp(const BlinkiteApp());
  }
}

class BlinkiteApp extends StatefulWidget {
  const BlinkiteApp({super.key});

  @override
  State<BlinkiteApp> createState() => _BlinkiteAppState();
}

class _BlinkiteAppState extends State<BlinkiteApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Animated Login',
      theme: _isDarkMode
          ? ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF0D0E17),
              fontFamily: 'Roboto',
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF3D5AFE),
                brightness: Brightness.dark,
              ),
            )
          : ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF5F5F5),
              fontFamily: 'Roboto',
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF3D5AFE),
                brightness: Brightness.light,
              ),
            ),
      home: FutureBuilder<bool>(
        future: _checkMockLogin(),
        builder: (context, mockSnapshot) {
          if (mockSnapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          
          if (mockSnapshot.data == true) {
            return AddressPage(onThemeToggle: _toggleTheme, isDarkMode: _isDarkMode);
          }

          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, firebaseSnapshot) {
              if (firebaseSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              
              if (firebaseSnapshot.hasData) {
                return AddressPage(onThemeToggle: _toggleTheme, isDarkMode: _isDarkMode);
              }

              return LoginPage(onThemeToggle: _toggleTheme, isDarkMode: _isDarkMode);
            },
          );
        },
      ),
    );
  }

  Future<bool> _checkMockLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isMockLoggedIn') ?? false;
  }
}
