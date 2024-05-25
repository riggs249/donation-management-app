import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'signin_page.dart';
import '../providers/auth_provider.dart';

class DonatePage extends StatelessWidget {

  bool? foodCheckboxValue = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donate'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await context.read<UserAuthProvider>().signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SignInPage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
             // Widget to display organizations
            CheckboxListTile(
              title: const Text("Food"),
              value: foodCheckboxValue,
              onChanged: (bool? value) {
                // setState(() {
                //   foodCheckboxValue = value;
                // })
              }
            ),
            SizedBox(height: 20),
             // Widget to display donors
          ],
        ),
      ),
    );
  }
}

