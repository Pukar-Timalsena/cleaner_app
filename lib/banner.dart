import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'responsive_utils.dart';

class BeginPage extends StatelessWidget {
  const BeginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      body: Stack(
        children: [
          /// 🔹 Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/welcome.png",
              fit: BoxFit.cover,
            ),
          ),

          /// 🔹 Main Content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                /// 🔹 Center Title
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.horizontalPadding * 2,
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Safai Yojana",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: responsive.responsiveFontSize(
                            32,
                            tabletSize: 42,
                            desktopSize: 54,
                          ),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),

                      SizedBox(height: responsive.spacing(8)),

                      Text(
                        "A Cleaning Service",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: responsive.responsiveFontSize(
                            14,
                            tabletSize: 18,
                            desktopSize: 20,
                          ),
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),


                SizedBox(height: responsive.spacing(120)), // Space before buttons

                /// 🔹 Buttons
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.horizontalPadding,
                  ),
                  child: Column(
                    children: [

                      /// LOGIN BUTTON
                      SizedBox(
                        height: responsive.buttonHeight,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Loginpage(),
                              ),
                            );
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: responsive.responsiveFontSize(
                                18,
                                tabletSize: 20,
                                desktopSize: 22,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: responsive.spacing(15)),

                      /// SIGN UP BUTTON
                      SizedBox(
                        height: responsive.buttonHeight,
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Signup(),
                              ),
                            );
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: responsive.responsiveFontSize(
                                18,
                                tabletSize: 20,
                                desktopSize: 22,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
