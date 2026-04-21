import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
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

  final AuthService _authService = AuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  String _selectedGender = 'Male';
  bool _isLoginMode = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

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
    _phoneController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  Color _fade(Color color, double opacity) {
    return Color.fromRGBO(color.red, color.green, color.blue, opacity);
  }

  InputDecoration _buildInputDecoration(String label, Color accent, {Widget? suffixIcon, IconData? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _fade(accent, 0.92)),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: _fade(accent, 0.7), size: 20) : null,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final formWidth = min(size.width * 0.9, 420.0);

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 16),
              child: AnimatedBuilder(
                animation: Listenable.merge([_glowController, _pulseController]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: formWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // Background ring - Fixed size and IgnorePointer to prevent layout issues
                          IgnorePointer(
                            child: SizedBox(
                              width: formWidth,
                              height: formWidth,
                              child: CustomPaint(
                                painter: _RingPainter(
                                  rotation: _glowController.value,
                                  innerScale: _pulseAnimation.value,
                                ),
                              ),
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
          ),
          Positioned(
            top: 50,
            left: 20,
            child: KBLogo(size: 60),
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: _primaryBlue),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
              style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
              decoration: _buildInputDecoration('Full Name', _primaryBlue, prefixIcon: Icons.person_outline),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              focusNode: _emailFocus,
              cursorColor: _primaryMagenta,
              style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
              decoration: _buildInputDecoration('Email Address', _primaryMagenta, prefixIcon: Icons.email_outlined),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              focusNode: _phoneFocus,
              keyboardType: TextInputType.phone,
              cursorColor: _primaryBlue,
              style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
              decoration: _buildInputDecoration('Phone Number', _primaryBlue, prefixIcon: Icons.phone_outlined),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: _fade(Colors.white, 0.03),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: _fade(_primaryMagenta, 0.32), width: 2),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedGender,
                  isExpanded: true,
                  dropdownColor: _backgroundEnd,
                  style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
                  items: ['Male', 'Female', 'Other'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedGender = newValue!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_isLoginMode) ...[
            TextField(
              controller: _usernameController,
              focusNode: _usernameFocus,
              cursorColor: _primaryBlue,
              style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
              decoration: _buildInputDecoration('Email', _primaryBlue, prefixIcon: Icons.email_outlined),
            ),
          ] else ...[
            // For signup, use password field directly
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            obscureText: _obscurePassword,
            cursorColor: _primaryMagenta,
            style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
            decoration: _buildInputDecoration(
              'Password', 
              _primaryMagenta,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: _fade(_primaryMagenta, 0.7),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
          Row(
            children: [
              Expanded(child: Divider(color: widget.isDarkMode ? Colors.white24 : Colors.black12)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('OR', style: TextStyle(color: widget.isDarkMode ? Colors.white38 : Colors.black38, fontSize: 12)),
              ),
              Expanded(child: Divider(color: widget.isDarkMode ? Colors.white24 : Colors.black12)),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _handleGoogleSignIn,
              icon: Icon(
                Icons.g_mobiledata, // Using a built-in icon instead of network image
                color: widget.isDarkMode ? Colors.white : Colors.black,
                size: 28,
              ),
              label: Text(
                'Continue with Google',
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
        ],
      ),
    );
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    
    final email = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter both email and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.login(email, password);
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'An error occurred during login');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignup() async {
    FocusScope.of(context).unfocus();
    
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      _showError('Please fill all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signUp(
        name: name,
        email: email,
        phone: phone,
        gender: _selectedGender,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during sign up: ${e.code} - ${e.message}');
      if (e.code == 'email-already-in-use') {
        _showError('Notification: This email already exists. Please login.');
      } else if (e.code == 'weak-password') {
        _showError('The password provided is too weak.');
      } else if (e.code == 'operation-not-allowed') {
        _showError('Email/password sign-up is disabled in Firebase Console.');
      } else {
        _showError(e.message ?? 'Sign-up failed: ${e.code}');
      }
    } catch (e) {
      debugPrint('Error during sign up: $e');
      _showError('Error saving user data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      _showError('Google Sign-In Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    
    // Use addPostFrameCallback to avoid "invoked during build" or engine dispatch errors on web
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(20),
          duration: const Duration(seconds: 4),
        ),
      );
    });
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
