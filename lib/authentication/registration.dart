import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dinengo/authentication/login.dart';
import '../Async/async_app.dart';
import '../Services/auth_service.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  final Color themeColor = const Color(0xFFFF6F00);

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final response = await AuthService.register(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: 'user',
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim(),
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

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', idToken);
      await prefs.setString('idToken', idToken);
      await prefs.setString('refreshToken', refreshToken);
      await prefs.setInt('tokenExpiresAt', expiresAtMs);
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
        SnackBar(content: Text('Welcome, ${user['firstName'] ?? 'User'}!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainApp()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Registration failed')),
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
                children: [
                  // --- Header ---
                  Image.asset(
                    'assets/images/dineahead-logo.png',
                    height: 90,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "DineAhead",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Join the community and start your dining journey!",
                    style: TextStyle(
                      color: Colors.black54,
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // --- Registration Card ---
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
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
                          // First Name
                          TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              prefixIcon:
                                  Icon(Icons.person_outline, color: themeColor),
                              labelText: 'First Name',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    BorderSide(color: themeColor, width: 2),
                              ),
                            ),
                            validator: (value) {
                              final v = (value ?? '').trim();
                              if (v.isEmpty) return 'Enter first name';
                              if (v.length < 2)
                                return 'At least 2 characters required';
                              if (!RegExp(r"^[A-Za-z\-\s']{2,}$").hasMatch(v))
                                return 'Use letters only';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Last Name
                          TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              prefixIcon:
                                  Icon(Icons.person_outline, color: themeColor),
                              labelText: 'Last Name',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    BorderSide(color: themeColor, width: 2),
                              ),
                            ),
                            validator: (value) {
                              final v = (value ?? '').trim();
                              if (v.isEmpty) return 'Enter last name';
                              if (v.length < 2)
                                return 'At least 2 characters required';
                              if (!RegExp(r"^[A-Za-z\-\s']{2,}$").hasMatch(v))
                                return 'Use letters only';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Phone
                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              prefixIcon:
                                  Icon(Icons.phone_outlined, color: themeColor),
                              labelText: 'Phone Number',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    BorderSide(color: themeColor, width: 2),
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              final v = (value ?? '').trim();
                              if (v.isEmpty) return 'Enter phone number';
                              final digits = v.replaceAll(RegExp(r'\D'), '');
                              if (digits.length < 6 || digits.length > 15) {
                                return 'Enter a valid phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              prefixIcon:
                                  Icon(Icons.email_outlined, color: themeColor),
                              labelText: 'Email Address',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    BorderSide(color: themeColor, width: 2),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Enter your email';
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              prefixIcon:
                                  Icon(Icons.lock_outline, color: themeColor),
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    BorderSide(color: themeColor, width: 2),
                              ),
                            ),
                            obscureText: true,
                            validator: (value) {
                              final v = (value ?? '').trim();
                              if (v.isEmpty) return 'Enter your password';
                              if (v.length < 8)
                                return 'At least 8 characters required';
                              if (!RegExp(r'(?=.*[A-Z])').hasMatch(v))
                                return 'Include an uppercase letter';
                              if (!RegExp(r'(?=.*[a-z])').hasMatch(v))
                                return 'Include a lowercase letter';
                              if (!RegExp(r'(?=.*\d)').hasMatch(v))
                                return 'Include a number';
                              if (!RegExp(
                                      r'(?=.*[!@#\$%\^&\*\-_=+\[\]\{\}()|;:\\,.<>\/?])')
                                  .hasMatch(v)) {
                                return 'Include a symbol';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // --- Sign Up Button ---
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
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
                                      "Sign Up",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Already have an account
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account? ",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'Montserrat'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => LoginPage()),
                                ),
                                child: Text(
                                  "Log In",
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

                  const SizedBox(height: 30),

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
