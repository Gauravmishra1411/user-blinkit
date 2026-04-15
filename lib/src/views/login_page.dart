import 'dart:math';

import 'package:flutter/material.dart';
import 'address_page.dart';
import '../widgets/kb_logo.dart';


class LoginPage extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const LoginPage({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late final AnimationController _glowController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  bool _isLoginMode = true;

  static const Color _primaryBlue = Color(0xFF39D2FF);
  static const Color _primaryMagenta = Color(0xFFE57CFF);
  static const Color _backgroundStart = Color(0xFF090A12);
  static const Color _backgroundEnd = Color(0xFF110F23);

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseAnimation = Tween(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Color _fade(Color color, double opacity) {
    return Color.fromRGBO(color.red, color.green, color.blue, opacity);
  }

  InputDecoration _buildInputDecoration(String label, Color accent) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _fade(accent, 0.92)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(width: 2, color: _fade(accent, 0.32)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(width: 2.5, color: accent),
      ),
      filled: true,
      fillColor: _fade(Colors.white, 0.03),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final formWidth = min(size.width * 0.9, 378.0); // max card width ≈ 10 cm at standard screen density

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_backgroundStart, _backgroundEnd],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _BackgroundGlowPainter(_glowController.value),
                );
              },
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_glowController, _pulseController]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: SizedBox(
                    width: formWidth,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: Size(formWidth, formWidth * 0.83),
                          painter: _RingPainter(
                            rotation: _glowController.value,
                            innerScale: _pulseAnimation.value,
                          ),
                        ),
                        _buildLoginCard(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: KBLogo(size: 60),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _fade(Colors.white, 0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: _fade(Colors.white, 0.15), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _fade(Colors.black, 0.45),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isLoginMode ? 'Login' : 'Sign Up',
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : Colors.black,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          if (!_isLoginMode) ...[
            TextField(
              controller: _nameController,
              focusNode: _nameFocus,
              cursorColor: _primaryBlue,
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
              decoration: _buildInputDecoration('Name', _primaryBlue),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _emailController,
              focusNode: _emailFocus,
              cursorColor: _primaryMagenta,
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
              decoration: _buildInputDecoration('Email', _primaryMagenta),
            ),
            const SizedBox(height: 18),
          ],
          TextField(
            controller: _usernameController,
            focusNode: _usernameFocus,
            cursorColor: _primaryBlue,
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
            decoration: _buildInputDecoration(_isLoginMode ? 'Email' : 'Username', _primaryBlue),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            obscureText: true,
            cursorColor: _primaryMagenta,
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
            decoration: _buildInputDecoration('Password', _primaryMagenta),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoginMode ? _handleLogin : _handleSignup,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F8EFE),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 12,
                shadowColor: const Color(0xFF4F8EFE).withOpacity(0.35),
              ),
              child: Text(
                _isLoginMode ? 'Login' : 'Sign Up',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 18),
          TextButton(
            onPressed: _toggleMode,
            child: Text(
              _isLoginMode ? 'Don\'t have an account? Sign Up' : 'Already have an account? Login',
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Divider(
            color: widget.isDarkMode ? Colors.white24 : Colors.black12,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _handleGoogleSignIn,
              icon: Icon(
                Icons.g_mobiledata,
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
              label: Text(
                _isLoginMode ? 'Sign in with Google' : 'Sign up with Google',
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: widget.isDarkMode ? Colors.white24 : Colors.black12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _isLoginMode ? 'Enter your credentials to continue' : 'Create your account to get started',
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
  }

  void _handleLogin() {
    FocusScope.of(context).unfocus();
    
    final email = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (email == 'user@gmail.com' && password == 'user123') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddressPage(
            onThemeToggle: widget.onThemeToggle,
            isDarkMode: widget.isDarkMode,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Authentication Error: Invalid email or password'),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(20),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  void _handleSignup() {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sign Up pressed (placeholder action)')),
    );
  }

  void _handleGoogleSignIn() {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google sign-in pressed (placeholder action)')),
    );
  }
}

class _BackgroundGlowPainter extends CustomPainter {
  final double progress;

  _BackgroundGlowPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * 0.45;

    final glow1 = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFFFB7E3F).withOpacity(0.22), Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final glow2 = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF00C0FF).withOpacity(0.18), Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center.translate(80, -60), radius: radius * 0.75));

    canvas.drawCircle(center.translate(-40, -20), radius, glow1);
    canvas.drawCircle(center.translate(60, 40), radius * 0.85, glow2);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(progress * 2 * pi);
    canvas.translate(-center.dx, -center.dy);

    final rotationGlow = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * pi,
        colors: [
          const Color(0xFF009FFD).withOpacity(0.24),
          const Color(0xFFE64CFF).withOpacity(0.14),
          const Color(0xFFFA6400).withOpacity(0.12),
          const Color(0xFF009FFD).withOpacity(0.24),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.1));

    canvas.drawCircle(center, radius * 1.1, rotationGlow);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BackgroundGlowPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _RingPainter extends CustomPainter {
  final double rotation;
  final double innerScale;

  _RingPainter({required this.rotation, required this.innerScale});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = min(size.width, size.height) * 0.42;

    final ringPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * pi,
        colors: [
          const Color(0xFF39D2FF),
          const Color(0xFFE57CFF),
          const Color(0xFF39D2FF),
        ],
        stops: const [0.0, 0.55, 1.0],
        transform: GradientRotation(rotation * 2 * pi),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final glowPaint = Paint()
      ..color = const Color(0xFF39D2FF).withOpacity(0.14)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);

    canvas.drawCircle(center, radius * innerScale, glowPaint);
    canvas.drawCircle(center, radius, ringPaint);

    final accentPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, radius * 0.78, accentPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.innerScale != innerScale;
  }
}
