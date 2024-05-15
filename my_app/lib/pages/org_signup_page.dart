import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class OrgSignUpPage extends StatefulWidget {
  const OrgSignUpPage({Key? key}) : super(key: key);

  @override
  State<OrgSignUpPage> createState() => _SignUpState();
}

class _SignUpState extends State<OrgSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String? organizationName;
  String? proofOfLegitimacy;
  String? errorMessage;

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
                proofField,
                errorMessage != null ? signUpErrorMessage : Container(),
                submitButton,
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
          "Sign Up as an Organization",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      );

  Widget get nameField => Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: TextFormField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Organization Name",
            hintText: "Enter the organization name",
          ),
          onSaved: (value) => setState(() => organizationName = value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter the organization name";
            }
            return null;
          },
        ),
      );

  Widget get proofField => Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Proof of Legitimacy",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO
              },
              child: Text("Choose File"),
            ),
          ],
        ),
      );

  Widget get submitButton => ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            Navigator.pop(context);
          }
        },
        child: const Text("Sign Up"),
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
