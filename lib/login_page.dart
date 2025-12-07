import 'package:clean_service/services/api_service.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'responsive_utils.dart';
import 'signup_page.dart';
import 'admin.dart';
import 'cleaner.dart';


class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    // Prevent multiple login attempts
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.loginUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (result['success'] == true) {
        _emailController.clear();
        _passwordController.clear();

        final user = result['user'];

        // Save user data for later use
        await ApiService.saveUserData(user);

        if (!mounted) return;

        Widget destination;
        switch (user['role']) {
          case 'admin':
            destination = const AdminDashboard();
            break;
          case 'cleaner':
            destination = const CleanerDashboard();
            break;
          case 'customer':
          default:
            destination = Homepage(
              userName: user['name'],
              userEmail: user['email'],
              userType: 'Customer',
            );
        }

        // Reset loading state before navigation
        setState(() {
          _isLoading = false;
        });

        // Navigate to destination
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        _showError('Login failed: ${result['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError('An error occurred: $e');
      }
    }
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
    _emailController.dispose();
    _passwordController.dispose();
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: responsive.spacing(80)),
            Padding(
              padding: EdgeInsets.all(responsive.spacing(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: responsive.responsiveFontSize(40, tabletSize: 48, desktopSize: 56),
                    ),
                  ),
                  SizedBox(height: responsive.spacing(10)),
                  Text(
                    "Welcome Back",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: responsive.responsiveFontSize(18, tabletSize: 20, desktopSize: 22),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
            // Use Expanded to avoid overflow on smaller viewports
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
                    padding: EdgeInsets.all(responsive.spacing(20)),
                    child: Column(
                      children: <Widget>[
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
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(responsive.spacing(10)),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.grey),
                                  ),
                                ),
                                child: TextField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    hintText: "Email or Phone number",
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: responsive.responsiveFontSize(14, tabletSize: 15, desktopSize: 16),
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  style: TextStyle(fontSize: responsive.responsiveFontSize(14, tabletSize: 15, desktopSize: 16)),
                                ),
                              ),
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
                                  decoration: InputDecoration(
                                    hintText: "Password",
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: responsive.responsiveFontSize(14, tabletSize: 15, desktopSize: 16),
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  style: TextStyle(fontSize: responsive.responsiveFontSize(14, tabletSize: 15, desktopSize: 16)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: responsive.spacing(40)),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Forget Password?",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: responsive.responsiveFontSize(14, tabletSize: 15, desktopSize: 16),
                              ),
                            ),

                            // ⭐ Updated Sign Up text
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Signup()),
                                );
                              },
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: responsive.responsiveFontSize(14, tabletSize: 15, desktopSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),


                        SizedBox(height: responsive.spacing(40)),

                        // LOGIN BUTTON
                        GestureDetector(
                          onTap: _isLoading ? null : _handleLogin,
                          child: Container(
                            height: responsive.buttonHeight,
                            margin: EdgeInsets.symmetric(horizontal: responsive.isMobile ? 50 : 30),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: _isLoading 
                                  ? const Color.fromARGB(255, 13, 153, 31).withOpacity(0.7)
                                  : const Color.fromARGB(255, 13, 153, 31),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : Text(
                                      "Login",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: responsive.responsiveFontSize(28, tabletSize: 30, desktopSize: 32),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ), // close Container
          ), // close Expanded
          ],
        ),
      ),
    );
  }
}
