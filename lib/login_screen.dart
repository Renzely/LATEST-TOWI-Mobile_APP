// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, unnecessary_null_comparison, use_key_in_widget_constructors, avoid_print, await_only_futures, file_names

import 'package:demo_app/forgotPass_screen.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/dashboard_screen.dart';
import 'package:demo_app/signUp_screen.dart';
import 'package:demo_app/dbHelper/mongodb.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String usernameErrorText = '';
  String passwordErrorText = '';

  Future<void> _login(BuildContext context) async {
    final String username = usernameController.text;
    final String password = passwordController.text;

    try {
      final userDetails =
          await MongoDatabase.getUserDetailsByUsername(username);
      if (userDetails != null) {
        final String storedPasswordHash = userDetails['password'];
        final bool isActivated = userDetails['isActivate'];

        // Check if the user is activated
        if (!isActivated) {
          // User is deactivated, prevent login
          setState(() {
            usernameErrorText = '';
            passwordErrorText = 'Account deactivated. Please contact admin.';
          });
          return; // Exit the method
        }

        // Validate the password using the validatePassword function
        if (await validatePassword(password, storedPasswordHash)) {
          // Passwords match, proceed with login
          print("Login successful");
          // Save login state and user details
          final prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLoggedIn', true);
          prefs.setString('userName', userDetails['firstName'] ?? '');
          prefs.setString('userLastName', userDetails['lastName'] ?? '');
          prefs.setString('userEmail', userDetails['emailAddress'] ?? '');

          // Use pushReplacement to navigate to Dashboard or perform any other actions after successful login
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => SideBarLayout(
                title: "Dashboard",
                mainContent: DateTimeWidget(),
                userName: userDetails['firstName'] ?? '',
                userLastName: userDetails['lastName'] ?? '',
                userEmail: userDetails['emailAddress'] ?? '',
              ),
            ),
            (route) => false, // This removes all routes from the stack
          );
        } else {
          setState(() {
            passwordErrorText = 'Invalid password';
          });
        }
      } else {
        setState(() {
          usernameErrorText = 'Invalid username';
        });
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("An error occurred during login. Please try again."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  Future<bool> validatePassword(
      String providedPassword, String storedPasswordHash) async {
    try {
      // Compare the provided password with the hashed password stored in the database
      return await BCrypt.checkpw(providedPassword, storedPasswordHash);
    } catch (e) {
      // Handle error
      print("Error validating password: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green[900]!,
              Colors.green[800]!,
              Colors.green[400]!,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 80),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Login",
                    style:
                        GoogleFonts.roboto(color: Colors.white, fontSize: 40),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Welcome to TOWI",
                    style:
                        GoogleFonts.roboto(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 60,
                      ),
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(63, 172, 48, 0.808),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            // Username Text Field with Title
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Username',
                                  style: GoogleFonts.roboto(
                                    color: Colors.green[900],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextFormField(
                                  controller: usernameController,
                                  onChanged: (_) {
                                    setState(() {
                                      usernameErrorText = '';
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Enter your username',
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.account_box),
                                    errorText: usernameErrorText.isNotEmpty
                                        ? usernameErrorText
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20), // Adjust spacing as needed
                            // Password Text Field with Title
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Password',
                                  style: GoogleFonts.roboto(
                                    color: Colors.green[900],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextFormField(
                                  controller: passwordController,
                                  onChanged: (_) {
                                    setState(() {
                                      passwordErrorText = '';
                                    });
                                  },
                                  obscureText: true, // To hide password
                                  decoration: InputDecoration(
                                    hintText: 'Enter your password',
                                    prefixIcon: Icon(Icons.lock),
                                    border: InputBorder.none,
                                    errorText: passwordErrorText.isNotEmpty
                                        ? passwordErrorText
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _login(context); // Call the login method
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: SizedBox(
                          width: 200, // Set a fixed width for the button
                          height: 50,
                          child: Center(
                            child: Text(
                              "Login",
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate to sign-up page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUp(),
                            ),
                          );
                        },
                        child: Text(
                          'SIGN UP',
                          style: GoogleFonts.roboto(
                            color: Colors.blueAccent[200],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate to forgot password page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPassword(),
                            ),
                          );
                        },
                        child: Text(
                          'FORGOT PASSWORD',
                          style: GoogleFonts.roboto(
                            color: Colors.blueAccent[200],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
