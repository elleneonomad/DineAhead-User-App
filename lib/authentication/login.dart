import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Async/async_app.dart';
import '../Services/api_service.dart';
import 'registration.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  void _loadSavedCredentials() async {
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

  void _saveCredentials(String email, String password, String token) async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('email', email);
      await prefs.setString('password', password);
      await prefs.setString('token', token);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.remove('token');
      await prefs.setBool('rememberMe', false);
    }
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final response = await ApiService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (response['success']) {
      final data = response['data'] ?? {};
      final user = data['user'] ?? {};
      final token = data['token'] ?? '';
      final name = user['name'] ?? 'User';

      _saveCredentials(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        token,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome back, $name!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainApp()),
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
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.arrow_back,
                      color: Color(0xFFFF6F00),
                      size: 32,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Welcome back to ',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                          color: Colors.black)),
                  Text('DineNGo',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                          color: Color(0xFFFF6F00))),
                ],
              ),
              SizedBox(height: 48),
              Text('Log In',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                      color: Colors.black)),
              SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter your email';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
                      return 'Please enter a valid email';
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter your password';
                    return null;
                  },
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF6F00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Log In',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                          )),
                ),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        activeColor: Color(0xFFFF6F00),
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value!;
                          });
                        },
                      ),
                      Text('Remember Me',
                          style: TextStyle(
                            color: Color(0xFFFF6F00),
                            fontFamily: 'Montserrat',
                          )),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFFFF6F00),
                          fontFamily: 'Montserrat',
                        )),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                      endIndent: 10,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ",
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'Montserrat',
                          )),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegistrationPage()),
                          );
                        },
                        child: Text('Sign Up',
                            style: TextStyle(
                                color: Color(0xFFFF6F00),
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),

              // --- Bottom Images Row ---
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.rotate(
                      angle: 0.3,
                      child: Image.asset(
                        'assets/images/salad.png',
                        height: 160,
                        width: 160,
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/facebook.png',
                            height: 36,
                            width: 36,
                          ),
                          SizedBox(width: 20),
                          Image.asset(
                            'assets/images/google.png',
                            height: 36,
                            width: 36,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
