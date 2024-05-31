import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../providers/auth_provider.dart';

class OrgSignUpPage extends StatefulWidget {
  const OrgSignUpPage({super.key});

  @override
  State<OrgSignUpPage> createState() => _SignUpState();
}

class _SignUpState extends State<OrgSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String? organizationName;
  String? description;
  String? email;
  String? password;
  String? address;
  String? contactNo;
  String? proofOfLegitimacy;
  String? errorMessage;
  bool isLoading = false;
  File? _proofImage;

  Future<void> _choosePhotoProof() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _proofImage = imageFile;
      });

      // Upload image to Firebase Storage
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('photo_proofs/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = storageRef.putFile(imageFile);
        final snapshot = await uploadTask.whenComplete(() {});
        final imageUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          proofOfLegitimacy = imageUrl;
        });
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  void _showPhotoProofDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Image.network(imageUrl),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close', style: TextStyle(color: Colors.teal)),
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
                descriptionField,
                emailField,
                passwordField,
                addressField,
                contactNoField,
                proofField,
                if (proofOfLegitimacy != null)
                  InkWell(
                    onTap: () => _showPhotoProofDialog(proofOfLegitimacy!),
                    child: Text(
                      'View Photo Proof',
                      style: TextStyle(
                        color: Colors.teal,
                      ),
                    ),
                  ),
                errorMessage != null ? signUpErrorMessage : Container(),
                isLoading ? const CircularProgressIndicator() : submitButton,
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
            labelText: "Organization Name",
            hintText: "Enter the organization name",
          ),
          onSaved: (value) => organizationName = value,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter the organization name";
            }
            return null;
          },
        ),
      );

  Widget get descriptionField => Padding(
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
            labelText: "Description",
            hintText: "Enter the organization description",
          ),
          onSaved: (value) => description = value,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter the organization description";
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

  Widget get proofField => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _choosePhotoProof,
              child: Text(
                'Choose Photo Proof (Required)',
                style: TextStyle(
                  color: Colors.white, // Font color of the button text
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50), // Custom border radius
                ),
                padding: const EdgeInsets.symmetric(vertical: 20), // Custom padding
                minimumSize: Size(350, 0), // Minimum button width
              ),
            ),
          ],
        ),
      );

  Widget get submitButton => Padding(
  padding: const EdgeInsets.symmetric(vertical: 20.0), // Adjust the padding as needed
  child: ElevatedButton(
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
              .signUpOrganization(
                organizationName!,
                description!,
                email!,
                password!,
                address!,
                contactNo!,
                proofOfLegitimacy!,
              );
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
    ),
  );


  Widget get signUpErrorMessage => Text(
        errorMessage ?? "",
        style: const TextStyle(color: Colors.red),
      );
}
