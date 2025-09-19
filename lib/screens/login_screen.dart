// File: lib/screens/login_screen.dart

import 'package:flutter/material.dart';
// මෙම line එකේ 'trip_planner_app' වෙනුවට ඔබගේ package නම යොදන්න.
// එය pubspec.yaml file එකේ 'name:' යටතේ සොයාගත හැක.
import 'package:trip_planner_app/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // AuthService class එකෙන් instance එකක් සාදා ගැනීම.
  // User login/signup işlemleri සඳහා මෙය භාවිතා කරයි.
  final AuthService _authService = AuthService();

  // TextField වලට ඇතුලත් කරන දත්ත ලබාගැනීම සඳහා Controllers.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // UI එකේ තත්ත්වය පාලනය කිරීමට අවශ්‍ය variables.
  bool _isLogin =
      true; // Login form එකද Signup form එකද පෙන්වන්නේ යන්න තීරණය කරයි.
  bool _isLoading =
      false; // දත්ත process වන විට loading indicator එකක් පෙන්වීමට.
  String _errorMessage = ''; // දෝෂයක් ඇති වූ විට පෙන්වීමට.

  // මතක තබාගන්න: Widget එක dispose වන විට controllers ද dispose කළ යුතුයි.
  // නැතිනම් memory leaks ඇතිවිය හැක.
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Login හෝ Signup බොත්තම එබූ විට ක්‍රියාත්මක වන ප්‍රධාන function එක.
  void _submit() async {
    // Form එක submit කළ විට loading indicator එක පෙන්වා, පරණ error messages මකා දමයි.
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // TextField වලින් email සහ password ලබාගැනීම.
    // .trim() මගින් අනවශ්‍ය හිස්තැන් ඉවත් කරයි.
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // User ට Login වීමට අවශ්‍යද නැතිනම් Signup වීමට අවශ්‍යද යන්න පරීක්ෂා කිරීම.
    if (_isLogin) {
      // Login ක්‍රියාවලිය
      final user = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );
      // Login අසාර්ථක වුවහොත් (user = null) error message එකක් පෙන්වීම.
      if (user == null) {
        setState(() {
          _errorMessage = 'Could not sign in. Please check your credentials.';
        });
      }
    } else {
      // Signup ක්‍රියාවලිය
      final user = await _authService.signUpWithEmailAndPassword(
        email,
        password,
      );
      // Signup අසාර්ථක වුවහොත් (user = null) error message එකක් පෙන්වීම.
      if (user == null) {
        setState(() {
          _errorMessage =
              'Could not sign up. The password must be at least 6 characters long.';
        });
      }
    }

    // ක්‍රියාවලිය අවසන් වූ පසු loading indicator එක ඉවත් කිරීම.
    // 'mounted' property එක මගින් widget එක තවමත් screen එකේ තිබේදැයි පරීක්ෂා කරයි.
    // මෙය අත්‍යවශ්‍ය වන්නේ async ක්‍රියාවලියක් නිසාය.
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // background වර්ණය මදක් වෙනස් කිරීම.
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        // Screen එකේ top/bottom notches වලින් UI එක ආරක්ෂා කරගැනීමට.
        child: Center(
          child: SingleChildScrollView(
            // Keyboard එක open වන විට UI එක scroll කිරීමට ඉඩ සලසයි.
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. App Logo සහ Title
                Icon(
                  Icons.travel_explore_rounded,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  _isLogin ? 'Welcome Back!' : 'Create Account',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Plan your next adventure with us',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 40),

                // 2. Email TextField
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // 3. Password TextField
                TextField(
                  controller: _passwordController,
                  obscureText: true, // Password එක තිත් ලෙස පෙන්වීමට.
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Error Message පෙන්වන Widget
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // 5. Login/Signup Button
                // _isLoading true නම්, Loading indicator එක පෙන්වයි. නැතිනම් Button එක පෙන්වයි.
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: Text(
                          _isLogin ? 'Login' : 'Sign Up',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                const SizedBox(height: 16),

                // 6. Login සහ Signup අතර මාරු වීමට අවශ්‍ය TextButton
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin
                          ? "Don't have an account?"
                          : "Already have an account?",
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin =
                              !_isLogin; // true නම් false, false නම් true කරයි.
                          _errorMessage =
                              ''; // Form මාරු කරන විට error message එක ඉවත් කරයි.
                        });
                      },
                      child: Text(
                        _isLogin ? 'Sign Up' : 'Login',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
