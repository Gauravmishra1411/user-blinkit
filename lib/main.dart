import 'package:flutter/material.dart';
import 'src/views/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BlinkiteApp());
}

class BlinkiteApp extends StatefulWidget {
  const BlinkiteApp({super.key});

  @override
  State<BlinkiteApp> createState() => _BlinkiteAppState();
}

class _BlinkiteAppState extends State<BlinkiteApp> {
  bool _isDarkMode = true;

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
      home: LoginPage(onThemeToggle: _toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}
