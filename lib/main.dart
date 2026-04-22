// Vercel Deployment Trigger: 2026-04-18
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'src/views/login_page.dart';
import 'src/views/address_page.dart';
import 'src/views/onboarding_page.dart';

void main() async {
  // Catch all Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    debugPrint('Caught Flutter Error: ${details.exception}');
  };

  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Load .env for local development (optional, can be used for other keys)
    try {
      await dotenv.load(fileName: ".env");
    } catch (_) {}

    debugPrint('Firebase App Initializing with DefaultFirebaseOptions...');
    
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
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
  bool _showOnboarding = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showOnboarding = prefs.getBool('onboarding_seen') != true;
    });
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    setState(() {
      _showOnboarding = false;
    });
  }

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

          if (_showOnboarding) {
            return OnboardingPage(
              onFinish: _completeOnboarding,
              isDarkMode: _isDarkMode,
            );
          }

          return LoginPage(onThemeToggle: _toggleTheme, isDarkMode: _isDarkMode);
        },
      ),
    );
  }
}
