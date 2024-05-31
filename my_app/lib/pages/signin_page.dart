import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './admin_page.dart';
import './donor_page.dart';
import './organization_home_page.dart';
import '../providers/auth_provider.dart';
import 'default_signup_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  String? errorMessage;
  bool _obscurePassword = true; // State variable to toggle password visibility
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 100, horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                heading,
                emailField,
                passwordField,
                errorMessage != null ? signInErrorMessage : Container(),
                submitButton,
                googleSignInButton,
                signUpButton,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get heading => Padding(
    padding: const EdgeInsets.only(bottom: 30),
    child: Text(
      "Sign In",
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.teal),
    ),
  );

  Widget get emailField => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal),
          borderRadius: BorderRadius.circular(50),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        labelText: "Email",
        hintText: "youremail@example.com",
        prefixIcon: Icon(Icons.email),
      ),
      onSaved: (value) => setState(() => email = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your email";
        }
        return null;
      },
    ),
  );

  Widget get passwordField => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal),
          borderRadius: BorderRadius.circular(50),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        labelText: "Password",
        hintText: "******",
        prefixIcon: Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      obscureText: _obscurePassword,
      onSaved: (value) => setState(() => password = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your password";
        } else if (value.length < 6) {
          return "Password must be at least 6 characters long";
        }
        return null;
      },
    ),
  );

  Widget get signInErrorMessage {
    String message = errorMessage ?? "An error occurred";
    switch (errorMessage) {
      case 'invalid-email':
        message = 'Invalid email format!';
        break;
      case 'user-disabled':
        message = 'User account disabled!';
        break;
      case 'invalid-credential':
        message = 'Invalid sign in credentials!';
        break;
      case 'not-approved':
        message = 'Your organization is not yet approved by the admin!';
        break;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget get submitButton => ElevatedButton(
    onPressed: () async {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        String? result = await context.read<UserAuthProvider>().authService.signIn(email!, password!);

        if (result == "donor") {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Login Successful', style: TextStyle(color: Colors.black)),
                content: const Text('You have successfully logged in as a donor.', style: TextStyle(color: Colors.teal)),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => DonorPage()),
                      );
                    },
                    child: const Text('OK', style: TextStyle(color: Colors.black)),
                  ),
                ],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                backgroundColor: Colors.white,
              );
            },
          );
        } else if (result == "organization") {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Login Successful', style: TextStyle(color: Colors.black)),
                content: const Text('You have successfully logged in as an organization.', style: TextStyle(color: Colors.teal)),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => OrganizationHomePage()),
                      );
                    },
                    child: const Text('OK', style: TextStyle(color: Colors.black)),
                  ),
                ],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                backgroundColor: Colors.white,
              );
            },
          );
        } else if (result == "admin") {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Login Successful', style: TextStyle(color: Colors.black)),
                content: const Text('You have successfully logged in as an administrator.', style: TextStyle(color: Colors.teal)),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => AdminPage()),
                      );
                    },
                    child: const Text('OK', style: TextStyle(color: Colors.black)),
                  ),
                ],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                backgroundColor: Colors.white,
              );
            },
          );
        } else {
          setState(() {
            errorMessage = result ?? "Unknown error";
          });
        }
      }
    },
    child: Text(
      'Sign In',
      style: TextStyle(
        color: Colors.white,
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.teal,
      padding: const EdgeInsets.symmetric(vertical: 15),
      minimumSize: Size(100, 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
    ),
  );

  Widget get googleSignInButton => ElevatedButton.icon(
  onPressed: () async {
    try {
      // Sign out the current user to force account chooser dialog
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential authResult = await _auth.signInWithCredential(credential);
        final User? user = authResult.user;

        if (user != null) {
          bool isDonor = await checkIfDonorExists(user.uid);
          if (!isDonor) {
            await addDonorToDatabase(user.uid, user.email);
          }
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Login Successful', style: TextStyle(color: Colors.black)),
                content: const Text('You have successfully logged in as a donor using google.', style: TextStyle(color: Colors.teal)),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => DonorPage()),
                      );
                    },
                    child: const Text('OK', style: TextStyle(color: Colors.black)),
                  ),
                ],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                backgroundColor: Colors.white,
              );
            },
          );
        }
      } else {
        print('Google Sign-In canceled.');
      }
    } catch (error) {
      print("Error signing in with Google: $error");
        setState(() {
          errorMessage = 'Error signing in with Google: $error';
        });
      }
    },
    icon: Icon(Icons.g_mobiledata),
    label: Text("Google"),
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 10),
      minimumSize: Size(100, 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
    )
  );


  Future<bool> checkIfDonorExists(String uid) async {
    try {
      DocumentSnapshot donorSnapshot = await _firestore.collection('donors').doc(uid).get();
      return donorSnapshot.exists;
    } catch (error) {
      print("Error checking if donor exists: $error");
      return false;
    }
  }

  Future<void> addDonorToDatabase(String uid, String? email) async {
    try {
      await _firestore.collection('donors').doc(uid).set({
        'email': email,
        'name': '',
        'address': '',
        'workAddress': '',
        'contactNo': '',
      });
    } catch (error) {
      print("Error adding donor to database: $error");
    }
  }

  Widget get signUpButton => Padding(
    padding: const EdgeInsets.all(30),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?"),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DefSignUpPage()),
            );
          },
          child: const Text("Sign Up"),
        ),
      ],
    ),
  );
}