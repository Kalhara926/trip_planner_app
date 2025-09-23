// File: lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:trip_planner_app/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await _authService.signUpWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
        _fullNameController.text,
        _usernameController.text,
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Create your account',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              _buildTextField(
                _emailController,
                'Email',
                keyboard: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _passwordController,
                'Password',
                isPassword: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(_fullNameController, 'Full name'),
              const SizedBox(height: 16),
              _buildTextField(_usernameController, 'Username'),
              const SizedBox(height: 40),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _handleSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A3FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Create account',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Or continue with',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              // Social buttons (UI only)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool isPassword = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
      ),
      validator: (value) => value!.isEmpty ? 'This field is required' : null,
    );
  }
}
