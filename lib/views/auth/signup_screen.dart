import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../home/home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  UserRole _selectedRole = UserRole.employee;
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _register() async {
    if (_isLoading) return; // Prevent multiple clicks
    
    print('Register button pressed');
    
    // Validation - Check for empty fields
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your name';
      });
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email';
      });
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a password';
      });
      return;
    }

    if (_confirmPasswordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please confirm your password';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Calling register service with email: ${_emailController.text.trim()}');
      
      UserModel? user = await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        role: _selectedRole,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timeout. Please check your internet connection.');
        },
      );

      print('Register result: ${user != null ? "Success" : "Failed"}');

      if (!mounted) return;

      if (user != null) {
        // Navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FeedScreen()),
        );
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Registration failed. Please try again.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Register error caught: $e');
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        // Clean up error message
        String errorMsg = e.toString();
        if (errorMsg.contains('email-already-in-use')) {
          _errorMessage = 'This email is already registered';
        } else if (errorMsg.contains('invalid-email')) {
          _errorMessage = 'Please enter a valid email';
        } else if (errorMsg.contains('weak-password')) {
          _errorMessage = 'Password is too weak';
        } else if (errorMsg.contains('network')) {
          _errorMessage = 'Network error. Check your connection.';
        } else if (errorMsg.contains('timeout')) {
          _errorMessage = 'Connection timeout. Please try again.';
        } else {
          _errorMessage = 'Registration failed. Please try again.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              const Text(
                "Let's start here",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red[800]),
                  ),
                ),
              
              // Name field
              _buildTextField(
                label: 'Name',
                hint: 'Enter Name',
                controller: _nameController,
                icon: Icons.person_outline,
              ),
              
              const SizedBox(height: 16),
              
              // Email field
              _buildTextField(
                label: 'Email',
                hint: 'Enter Email',
                controller: _emailController,
                icon: Icons.person_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: 16),
              
              // Username field
              _buildTextField(
                label: 'Username',
                hint: 'Enter Username',
                controller: _usernameController,
                icon: Icons.person_outline,
              ),
              
              const SizedBox(height: 16),
              
              // Password field
              _buildTextField(
                label: 'Password',
                hint: 'Type in your password',
                controller: _passwordController,
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              
              const SizedBox(height: 16),
              
              // Confirm Password field
              _buildTextField(
                label: 'Re-enter Password',
                hint: 'Re-type your password',
                controller: _confirmPasswordController,
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              
              const SizedBox(height: 24),
              
              // Role selection
              const Text(
                'Role',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Checkbox(
                          value: _selectedRole == UserRole.admin,
                          onChanged: (value) {
                            if (value == true) {
                              setState(() {
                                _selectedRole = UserRole.admin;
                              });
                            }
                          },
                          activeColor: const Color(0xFF2196F3),
                        ),
                        const Text('Admin'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Checkbox(
                          value: _selectedRole == UserRole.employee,
                          onChanged: (value) {
                            if (value == true) {
                              setState(() {
                                _selectedRole = UserRole.employee;
                              });
                            }
                          },
                          activeColor: const Color(0xFF2196F3),
                        ),
                        const Text('Employé'),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Remember me & Forgot password
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
                        activeColor: const Color(0xFF2196F3),
                      ),
                      const Text(
                        'Remember me',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot Password',
                      style: TextStyle(
                        color: Color(0xFF2196F3),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Sign Up button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Sign Up',
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

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2196F3)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}