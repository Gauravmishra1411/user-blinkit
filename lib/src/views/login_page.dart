import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
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

class _LoginPageState extends State<LoginPage> {
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
  static const Color _backgroundStart = Color(0xFF0D0E17);
  static const Color _backgroundEnd = Color(0xFF1A1C2C);

  @override
  void dispose() {
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

  InputDecoration _buildInputDecoration(String label, Color accent, {Widget? suffixIcon, IconData? prefixIcon}) {
    final isDark = widget.isDarkMode;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: accent, size: 20) : null,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(width: 1, color: isDark ? Colors.white10 : Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(width: 2, color: accent),
      ),
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final formWidth = min(size.width * 0.9, 420.0);

    return Scaffold(
      backgroundColor: widget.isDarkMode ? _backgroundStart : Colors.white,
      body: Stack(
        children: [
          if (widget.isDarkMode)
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
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
              child: SizedBox(
                width: formWidth,
                child: Column(
                  children: [
                    KBLogo(size: 80, isAnimated: false),
                    const SizedBox(height: 40),
                    _buildLoginCard(),
                  ],
                ),
              ),
            ),
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
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.white.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isDarkMode ? Colors.white10 : Colors.black12,
          width: 1,
        ),
        boxShadow: [
          if (!widget.isDarkMode)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isLoginMode ? 'Welcome Back' : 'Create Account',
            style: TextStyle(
              color: textColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          if (!_isLoginMode) ...[
            TextField(
              controller: _nameController,
              focusNode: _nameFocus,
              style: TextStyle(color: textColor),
              decoration: _buildInputDecoration('Full Name', _primaryBlue, prefixIcon: Icons.person_outline),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              focusNode: _emailFocus,
              style: TextStyle(color: textColor),
              decoration: _buildInputDecoration('Email Address', _primaryMagenta, prefixIcon: Icons.email_outlined),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              focusNode: _phoneFocus,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: textColor),
              decoration: _buildInputDecoration('Phone Number', _primaryBlue, prefixIcon: Icons.phone_outlined),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: widget.isDarkMode ? Colors.white10 : Colors.black12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedGender,
                  isExpanded: true,
                  dropdownColor: widget.isDarkMode ? _backgroundEnd : Colors.white,
                  style: TextStyle(color: textColor),
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
              style: TextStyle(color: textColor),
              decoration: _buildInputDecoration('Email', _primaryBlue, prefixIcon: Icons.email_outlined),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            obscureText: _obscurePassword,
            style: TextStyle(color: textColor),
            decoration: _buildInputDecoration(
              'Password', 
              _primaryMagenta,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: widget.isDarkMode ? Colors.white54 : Colors.black45,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoginMode ? _handleLogin : _handleSignup,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                _isLoginMode ? 'Login' : 'Sign Up',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Divider(color: widget.isDarkMode ? Colors.white10 : Colors.black12)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('OR', style: TextStyle(color: widget.isDarkMode ? Colors.white38 : Colors.black38, fontSize: 12)),
              ),
              Expanded(child: Divider(color: widget.isDarkMode ? Colors.white10 : Colors.black12)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: _handleGoogleSignIn,
              icon: Icon(
                Icons.g_mobiledata,
                color: textColor,
                size: 28,
              ),
              label: Text(
                'Continue with Google',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: widget.isDarkMode ? Colors.white10 : Colors.black12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
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
      _showError('${e.code}: ${e.message ?? 'An error occurred during login'}');
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
      
      await _authService.signOut();

      if (mounted) {
        _showSuccess('Account created successfully! Please login.');
        setState(() {
          _isLoginMode = true;
          _usernameController.text = email;
        });
      }
    } on FirebaseAuthException catch (e) {
      _showError('${e.code}: ${e.message ?? "Sign-up failed"}');
    } catch (e) {
      _showError('Error: $e');
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
