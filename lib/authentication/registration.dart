import 'package:flutter/material.dart';
import 'package:dinengo/authentication/login.dart';
import '../Async/async_app.dart';
import '../Services/api_service.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _verifyCodeController = TextEditingController();

  bool _isLoading = false;
  bool _codeSent = false;

  // Send verification code
  // Send verification code
  void _sendVerifyCode() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please enter your email")));
      return;
    }

    setState(() => _isLoading = true);

    final response =
        await ApiService.sendVerifyCode(_emailController.text.trim());

    setState(() => _isLoading = false);

    if (response['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Code sent")));
      print("Verify code response: $response");

      // ✅ Don't auto-fill the verification code
      // Just show the input field so the user can type the code from email
      setState(() => _codeSent = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['message'] ?? "Failed to send code")));
    }
  }

  // Register user
  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_codeSent) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Please send and enter the verification code")));
      return;
    }

    if (_verifyCodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter the verification code")));
      return;
    }

    setState(() => _isLoading = true);

    final response = await ApiService.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      verifyCode: _verifyCodeController.text.trim(), // ✅ user input code
      // avatar: "avatar.png",
    );

    setState(() => _isLoading = false);

    if (response['success']) {
      final data = response['data'];
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registered as ${data['name']}')));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainApp()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['message'] ?? 'Registration failed')));
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
              // Back button
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: Color(0xFFFF6F00), size: 32),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Welcome to ',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                          color: Colors.black)),
                  Text('DineNGo',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                          color: Color(0xFFFF6F00))),
                ],
              ),
              SizedBox(height: 32),

              Text('Sign Up',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                      color: Colors.black)),
              SizedBox(height: 32),

              // Name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your name' : null,
                ),
              ),
              SizedBox(height: 16),

              // Email + Send Code
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16)),
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
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _sendVerifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF6F00),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Send Code'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Verification code
              if (_codeSent)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextFormField(
                    controller: _verifyCodeController,
                    decoration: InputDecoration(
                      labelText: 'Verification Code',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter verification code' : null,
                  ),
                ),
              if (_codeSent) SizedBox(height: 16),

              // Password
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter your password';
                    if (value.length < 6)
                      return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
              ),
              SizedBox(height: 20),

              // Sign Up button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF6F00),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Sign Up',
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Montserrat',
                              color: Colors.white)),
                ),
              ),
              SizedBox(height: 12),

              // Already have account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ",
                      style: TextStyle(color: Colors.grey)),
                  TextButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => LoginPage())),
                    child: Text('Login',
                        style: TextStyle(
                            color: Color(0xFFFF6F00),
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),

              // Bottom images
              SizedBox(height: 40),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.rotate(
                    angle: 0.3,
                    child: Image.asset('assets/images/salad.png',
                        height: 160, width: 160),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Row(
                      children: [
                        Image.asset('assets/images/facebook.png',
                            height: 36, width: 36),
                        SizedBox(width: 20),
                        Image.asset('assets/images/google.png',
                            height: 36, width: 36),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
