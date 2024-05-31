import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'org_signup_page.dart';
import '../providers/auth_provider.dart';

class DefSignUpPage extends StatefulWidget {
  const DefSignUpPage({super.key});

  @override
  State<DefSignUpPage> createState() => _SignUpState();
}

class _SignUpState extends State<DefSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String? name;
  String? email;
  String? password;
  String? address;
  String? contactNo;
  String? errorMessage;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                heading,
                nameField,
                emailField,
                passwordField,
                addressField,
                contactNoField,
                errorMessage != null ? signUpErrorMessage : Container(),
                isLoading ? const CircularProgressIndicator() : submitButton,
                signUpButton,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get heading => const Padding(
        padding: EdgeInsets.only(bottom: 30),
        child: Text(
          "Sign Up as a Donor",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.teal), // Teal color for heading
        ),
      );

  Widget get nameField => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: TextFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50), // Custom border radius
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.teal), // Custom active color
              borderRadius: BorderRadius.circular(50), // Custom border radius
            ),
            filled: true, // Set to true to fill the background color
            fillColor: Colors.grey[50], // Background color of the input field
            labelText: "Name",
            hintText: "Enter your full name",
          ),
          onSaved: (value) => setState(() => name = value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter your full name";
            }
            return null;
          },
        ),
      );

  Widget get emailField => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: TextFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50), // Custom border radius
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.teal), // Custom active color
              borderRadius: BorderRadius.circular(50), // Custom border radius
            ),
            filled: true, // Set to true to fill the background color
            fillColor: Colors.grey[50], // Background color of the input field
            labelText: "Email",
            hintText: "Enter an email",
          ),
          onSaved: (value) => setState(() => email = value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter an email";
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
              borderRadius: BorderRadius.circular(50), // Custom border radius
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.teal), // Custom active color
              borderRadius: BorderRadius.circular(50), // Custom border radius
            ),
            filled: true, // Set to true to fill the background color
            fillColor: Colors.grey[50], // Background color of the input field
            labelText: "Password",
            hintText: "At least 6 characters",
          ),
          obscureText: true,
          onSaved: (value) => setState(() => password = value),
          validator: (value) {
            if (value == null || value.isEmpty || value.length < 6) {
              return "Please enter a valid password with at least 6 characters";
            }
            return null;
          },
        ),
      );

  Widget get addressField => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: TextFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50), // Custom border radius
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.teal), // Custom active color
              borderRadius: BorderRadius.circular(50), // Custom border radius
            ),
            filled: true, // Set to true to fill the background color
            fillColor: Colors.grey[50], // Background color of the input field
            labelText: "Address",
            hintText: "Enter your address",
          ),
          onSaved: (value) => setState(() => address = value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter your address";
            }
            return null;
          },
        ),
      );

  Widget get contactNoField => Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: TextFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50), // Custom border radius
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.teal), // Custom active color
              borderRadius: BorderRadius.circular(50), // Custom border radius
            ),
            filled: true, // Set to true to fill the background color
            fillColor: Colors.grey[50], // Background color of the input field
            labelText: "Contact No",
            hintText: "Enter your contact number",
          ),
          onSaved: (value) => setState(() => contactNo = value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter your contact number";
            }
            return null;
          },
        ),
      );

   Widget get submitButton => ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            setState(() {
              isLoading = true;
            });
            try {
              String? result = await context
                  .read<UserAuthProvider>()
                  .authService
                  .signUpDonor(name!, email!, password!, address!, contactNo!);
              if (mounted) {
                Navigator.pop(context);
              } else {
                setState(() {
                  errorMessage = result;
                });
              }
            } catch (e) {
              setState(() {
                errorMessage = 'An unexpected error occurred';
              });
            } finally {
              setState(() {
                isLoading = false;
              });
            }
          }
        },
        child: Text(
          'Sign Up',
          style: TextStyle(
            color: Colors.white, // Font color of the button text
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal, // Custom button color
          padding: const EdgeInsets.symmetric(vertical: 15), // Custom padding
          minimumSize: Size(100, 0), // Minimum button width
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50), // Custom border radius
          ),
        ),
      );

  Widget get signUpButton => Padding(
        padding: const EdgeInsets.all(30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Want to sign up as an organization?"),
            TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const OrgSignUpPage()));
                },
                child: const Text("Sign Up"))
          ],
        ),
      );      

  Widget get signUpErrorMessage {
    String message = errorMessage ?? "An error occurred";
    switch (errorMessage) {
      case 'invalid-email':
        message = 'Invalid email format!';
        break;
      case 'weak-password':
        message = 'Weak password, try a stronger one!';
        break;
      case 'email-already-in-use':
        message = 'Email already in use, please use a different email!';
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
}
