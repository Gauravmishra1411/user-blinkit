// Vercel Deployment Trigger: 2026-04-18
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'src/views/login_page.dart';
import 'src/views/address_page.dart';

void main() async {
  // Catch all Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    debugPrint('Caught Flutter Error: ${details.exception}');
  };

  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Load .env for local development
    try {
      await dotenv.load(fileName: ".env");
    } catch (_) {}

    // Get values from flags or .env fallback
    const fKey = String.fromEnvironment('FIREBASE_API_KEY');
    const fAuth = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
    const fProj = String.fromEnvironment('FIREBASE_PROJECT_ID');
    const fStor = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
    const fMess = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
    const fApp = String.fromEnvironment('FIREBASE_APP_ID');
    const fMeas = String.fromEnvironment('FIREBASE_MEASUREMENT_ID');

    final apiKey = fKey.isNotEmpty ? fKey : dotenv.get('FIREBASE_API_KEY', fallback: "");
    
    debugPrint('Firebase App Initializing...');
    debugPrint('API Key Status: ${apiKey.isNotEmpty ? "Available (${apiKey.substring(0, 5)}...)" : "MISSING"}');
    debugPrint('Project ID: ${fProj.isNotEmpty ? fProj : dotenv.get('FIREBASE_PROJECT_ID', fallback: "MISSING")}');

    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: apiKey,
        authDomain: fAuth.isNotEmpty ? fAuth : dotenv.get('FIREBASE_AUTH_DOMAIN', fallback: ""),
        projectId: fProj.isNotEmpty ? fProj : dotenv.get('FIREBASE_PROJECT_ID', fallback: ""),
        storageBucket: fStor.isNotEmpty ? fStor : dotenv.get('FIREBASE_STORAGE_BUCKET', fallback: ""),
        messagingSenderId: fMess.isNotEmpty ? fMess : dotenv.get('FIREBASE_MESSAGING_SENDER_ID', fallback: ""),
        appId: fApp.isNotEmpty ? fApp : dotenv.get('FIREBASE_APP_ID', fallback: ""),
        measurementId: fMeas.isNotEmpty ? fMeas : dotenv.get('FIREBASE_MEASUREMENT_ID', fallback: ""),
      ),
    );

    runApp(const BlinkiteApp());
  } catch (e, stack) {
    debugPrint('Fatal initialization error: $e');
    debugPrint('Stack trace: $stack');
    
    // Show error on screen if initialization fails
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SelectableText('Initialization Error: $e\n\nEnsure you added FIREBASE_* environment variables in the Vercel dashboard.'),
          ),
        ),
      ),
    ));
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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          
          if (snapshot.hasData) {
            return AddressPage(onThemeToggle: _toggleTheme, isDarkMode: _isDarkMode);
          }

          return LoginPage(onThemeToggle: _toggleTheme, isDarkMode: _isDarkMode);
        },
      ),
    );
  }
}
