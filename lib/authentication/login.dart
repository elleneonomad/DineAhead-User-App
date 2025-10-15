import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Async/async_app.dart';
import '../Services/auth_service.dart';
import 'registration.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  final Color themeColor = const Color(0xFFFF6F00);

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedPassword = prefs.getString('password');
    final remember = prefs.getBool('rememberMe') ?? false;

    if (remember && savedEmail != null && savedPassword != null) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveCredentials(
    String email,
    String password,
    String idToken,
    String refreshToken,
    int expiresAtMs,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('email', email);
      await prefs.setString('password', password);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.setBool('rememberMe', false);
    }

    await prefs.setString('token', idToken);
    await prefs.setString('idToken', idToken);
    await prefs.setString('refreshToken', refreshToken);
    await prefs.setInt('tokenExpiresAt', expiresAtMs);
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final response = await AuthService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (response['success']) {
      final user = (response['user'] ?? {}) as Map<String, dynamic>;
      final tokens = (response['tokens'] ?? {}) as Map<String, dynamic>;
      final idToken = (tokens['idToken'] ?? '') as String;
      final refreshToken = (tokens['refreshToken'] ?? '') as String;
      final expiresInStr = tokens['expiresIn']?.toString() ?? '0';
      final expiresIn = int.tryParse(expiresInStr) ?? 0;
      final expiresAtMs = DateTime.now()
          .add(Duration(seconds: expiresIn))
          .millisecondsSinceEpoch;

      final name = [user['firstName'], user['lastName']]
          .where((v) => (v ?? '').toString().isNotEmpty)
          .join(' ');

      await _saveCredentials(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        idToken,
        refreshToken,
        expiresAtMs,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', (tokens['uid'] ?? '').toString());
      await prefs.setString('userEmail', (user['email'] ?? '').toString());
      if (user['role'] != null)
        await prefs.setString('role', user['role'].toString());
      if (user['firstName'] != null)
        await prefs.setString('firstName', user['firstName'].toString());
      if (user['lastName'] != null)
        await prefs.setString('lastName', user['lastName'].toString());
      if (user['phone'] != null)
        await prefs.setString('phone', user['phone'].toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome back, ${name.isEmpty ? 'User' : name}!'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainApp()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFF3E0), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- Logo ---
                  Image.asset(
                    'assets/images/dineahead-logo.png',
                    height: 100,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "DineAhead",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Reserve • Pre-Order • Enjoy",
                    style: TextStyle(
                      color: Colors.black54,
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- Login Card ---
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text(
                            "Welcome back 👋",
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // --- Email field ---
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon:
                                  Icon(Icons.email_outlined, color: themeColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: themeColor,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // --- Password field ---
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon:
                                  Icon(Icons.lock_outline, color: themeColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: themeColor,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          // --- Remember me / Forgot password ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    activeColor: themeColor,
                                    onChanged: (v) =>
                                        setState(() => _rememberMe = v!),
                                  ),
                                  const Text(
                                    "Remember Me",
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: themeColor,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // --- Login button ---
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 3,
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text(
                                      "Log In",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // --- Sign up link ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don’t have an account? ",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => RegistrationPage()),
                                ),
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: themeColor,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- Footer ---
                  Column(
                    children: [
                      Divider(thickness: 1, color: Colors.grey[300]),
                      const SizedBox(height: 10),
                      Transform.rotate(
                        angle: 0.3,
                        child: Image.asset(
                          'assets/images/salad.png',
                          height: 130,
                          width: 130,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '© 2025 DineAhead. All rights reserved.',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reserve • Pre-Order • Enjoy',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          color: themeColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
