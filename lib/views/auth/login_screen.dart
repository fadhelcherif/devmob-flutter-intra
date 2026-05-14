import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String _rememberMeKey = 'remember_me';
  static const String _rememberedEmailKey = 'remembered_email';

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRememberedLogin();
  }

  Future<void> _loadRememberedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
    final rememberedEmail = prefs.getString(_rememberedEmailKey) ?? '';

    if (!mounted) return;

    setState(() {
      _rememberMe = rememberMe;
      if (rememberMe && rememberedEmail.isNotEmpty) {
        _emailController.text = rememberedEmail;
      }
    });
  }

  Future<void> _persistRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, _rememberMe);

    if (_rememberMe) {
      await prefs.setString(_rememberedEmailKey, _emailController.text.trim());
    } else {
      await prefs.remove(_rememberedEmailKey);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Enter your email first to reset password';
      });
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.sendPasswordResetEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Check your inbox.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not send reset email. Please verify your email.';
      });
    }
  }

  Future<void> _login() async {
    if (_isLoading) return; // Prevent multiple clicks

    print('Login button pressed');

    // Validation - Check for empty fields
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email';
      });
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Attempting login with email: ${_emailController.text.trim()}');

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final bool success = await authProvider
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your internet connection.',
              );
            },
          );
      final UserModel? user = success ? authProvider.user : null;

      print('Login result: ${user != null ? "Success" : "Failed"}');

      if (!mounted) return;

      if (user != null) {
        await _persistRememberMe();
        if (!mounted) return;

        // Navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FeedScreen()),
        );
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Login failed. Please try again.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Login error caught: $e');
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        String errorMsg = e.toString();
        if (errorMsg.contains('user-not-found')) {
          _errorMessage = 'No account found with this email';
        } else if (errorMsg.contains('wrong-password')) {
          _errorMessage = 'Incorrect password';
        } else if (errorMsg.contains('invalid-email')) {
          _errorMessage = 'Please enter a valid email';
        } else if (errorMsg.contains('invalid-credential')) {
          _errorMessage = 'Invalid email or password';
        } else if (errorMsg.contains('network')) {
          _errorMessage = 'Network error. Check your connection.';
        } else if (errorMsg.contains('timeout')) {
          _errorMessage = 'Connection timeout. Please try again.';
        } else {
          _errorMessage = 'Login failed. Please try again.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              Center(
                child: Image.asset(
                  'assets/icon.png',
                  width: 96,
                  height: 96,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Discover your favorite\nspaces with us!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 48),

              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: colorScheme.onErrorContainer),
                  ),
                ),

              if (_errorMessage != null) const SizedBox(height: 16),

              // Email field
              const Text(
                'Email',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Type your email',
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.primaryColor),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Password field
              const Text(
                'Password',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Type your password',
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.primaryColor),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        activeColor: theme.primaryColor,
                      ),
                      const Text('Remember me', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _forgotPassword,
                    style: TextButton.styleFrom(
                      foregroundColor: theme.primaryColor,
                    ),
                    child: const Text(
                      'Forgot Password',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: colorScheme.onPrimary)
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
