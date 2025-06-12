import 'package:dinengo/authentication/login.dart';
import 'package:flutter/material.dart';
import 'mock_api_service.dart';
import '../Async/async_app.dart'; // Import your main app widget

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _avatarPath;

  // void _pickAvatar() async {
  //   // Logic to pick an avatar (e.g., using image_picker package)
  //   setState(() {
  //     _avatarPath = 'path/to/avatar.png'; // Replace with actual file path
  //   });
  // }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final response = await MockApiService.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        'user', // default user type
        'avatar.png', // hardcoded avatar
      );

      if (response['success']) {
        final data = response['data'];
        print('Registration successful: ${data['name']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registered as ${data['name']}')),
        );
        // Navigate or save token here
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainApp()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Registration'),
      //   backgroundColor: Color(0xFFFF6F00), // Primary color
      // ),
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
                    onPressed: () {
                      // Navigator.pop(context); // Navigate back to the previous screen
                    },
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
              SizedBox(height: 48),
              Text(
                'Sign Up',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: Colors.black),
              ),
              SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'Montserrat',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),
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
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
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
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),
              // Row(
              //   children: [
              //     _avatarPath != null
              //         ? CircleAvatar(
              //             backgroundImage: AssetImage(_avatarPath!),
              //             radius: 30,
              //           )
              //         : CircleAvatar(
              //             child: Icon(Icons.person),
              //             radius: 30,
              //           ),
              //   ],
              // ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF6F00), // Primary color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   children: [
              //     TextButton(
              //       onPressed: () {
              //         // Navigate to login page
              //       },
              //       child: Text(
              //         'Forgot Password?',
              //         style: TextStyle(
              //           color: Color(0xFFFF6F00), // Primary color
              //           fontFamily: 'Montserrat',
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey, // Line color
                      thickness: 1,
                      endIndent: 10, // Space between line and text button
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to registration page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Color(0xFFFF6F00),
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 1.0), // Moves the whole row up a bit
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Aligns content to top
                  children: [
                    // Salad image (left and tilted)
                    Transform.rotate(
                      angle: 0.3,
                      child: Image.asset(
                        'assets/images/salad.png',
                        height: 160,
                        width: 160,
                      ),
                    ),

                    Spacer(),

                    // Facebook & Google icons evenly spaced in the same row
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 24.0), // Move logos up
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/facebook.png',
                            height: 36,
                            width: 36,
                          ),
                          SizedBox(width: 20), // Even spacing
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
