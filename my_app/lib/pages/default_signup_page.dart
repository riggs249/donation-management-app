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
  String? username;
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
                usernameField,
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
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      );

  Widget get nameField => Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: TextFormField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
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

  Widget get usernameField => Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: TextFormField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Username",
            hintText: "Enter a username",
          ),
          onSaved: (value) => setState(() => username = value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter a username";
            }
            return null;
          },
        ),
      );

  Widget get passwordField => Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: TextFormField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
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
        padding: const EdgeInsets.only(bottom: 30),
        child: TextFormField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
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
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
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
                  .signUpDonor(name!, username!, password!, address!, contactNo!);
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
        child: const Text("Sign Up"),
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
