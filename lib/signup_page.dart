import 'package:clean_service/services/api_service.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'responsive_utils.dart';

import 'home.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String userType = "Customer";
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Seed test accounts on first load if they don't exist
    ApiService.seedTestAccounts();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Color.fromARGB(255, 5, 58, 7),
              Colors.green,
              Colors.green,
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: responsive.spacing(60)),

            // Back Button + Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: responsive.responsiveFontSize(28, tabletSize: 30, desktopSize: 32),
                    ),
                  ),
                  SizedBox(width: responsive.spacing(12)),
                  Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: responsive.responsiveFontSize(32, tabletSize: 36, desktopSize: 40),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: responsive.spacing(30)),

            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: responsive.maxFormWidth),
                      padding: EdgeInsets.all(responsive.spacing(25)),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(responsive.spacing(20)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromRGBO(255, 95, 27, 0.3),
                                  blurRadius: responsive.cardElevation * 2.5,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Full Name
                                Container(
                                  padding: EdgeInsets.all(responsive.spacing(10)),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      hintText: "Full Name",
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),

                                // Email
                                Container(
                                  padding: EdgeInsets.all(responsive.spacing(10)),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      hintText: "Email",
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),

                                // Address
                                Container(
                                  padding: EdgeInsets.all(responsive.spacing(10)),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _addressController,
                                    decoration: const InputDecoration(
                                      hintText: "Address",
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),

                                // Phone number
                                Container(
                                  padding: EdgeInsets.all(responsive.spacing(10)),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: const InputDecoration(
                                      hintText: "Phone Number",
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),

                                // Password
                                Container(
                                  padding: EdgeInsets.all(responsive.spacing(10)),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      hintText: "Password",
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),

                                // User Type
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: responsive.spacing(10),
                                    vertical: responsive.spacing(5),
                                  ),
                                  child: DropdownButtonFormField(
                                    value: userType,
                                    decoration: const InputDecoration(
                                      hintText: "Type of User",
                                      border: UnderlineInputBorder(),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: "Customer",
                                        child: Text("Customer"),
                                      ),
                                      DropdownMenuItem(
                                        value: "Cleaner",
                                        child: Text("Cleaner"),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        userType = value.toString();
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),

                          SizedBox(height: responsive.spacing(40)),

                          // Sign Up Button
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                _isLoading = true;
                              });

                              try {
                                final Map<String, String> data = {
                                  'name': _nameController.text,
                                  'email': _emailController.text,
                                  'password': _passwordController.text,
                                  'address': _addressController.text,
                                  'phone': _phoneController.text,
                                  'role': userType.toLowerCase(),
                                };

                                final result = await ApiService.registerUser(data);

                                if (result['success']) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Homepage(
                                        userName: result['user']['name'],
                                        userEmail: result['user']['email'],
                                        userAddress: result['user']['address'],
                                        userPhone: result['user']['phone'],
                                        userType: result['user']['role'],
                                      ),
                                    ),
                                  );
                                } else {
                                  _showError('Registration failed: ${result['error']}');
                                }
                              } catch (e) {
                                _showError('An error occurred: $e');
                              } finally {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            },
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  )
                                : Container(
                                    height: responsive.buttonHeight,
                                    margin: EdgeInsets.symmetric(
                                        horizontal: responsive.isMobile ? 50 : 30),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: const Color.fromARGB(255, 13, 153, 31),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Sign Up",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: responsive.responsiveFontSize(
                                              26, tabletSize: 28, desktopSize: 30),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),

                          SizedBox(height: responsive.spacing(40)),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: responsive.responsiveFontSize(
                                      14, tabletSize: 15, desktopSize: 16),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Loginpage()),
                                  );
                                },
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: responsive.responsiveFontSize(
                                        14, tabletSize: 15, desktopSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
