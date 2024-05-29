import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:week9_authentication/api/firebase_auth_api.dart';
import 'signin_page.dart';
import '../providers/auth_provider.dart';

class DonatePage extends StatefulWidget {
  const DonatePage({super.key});

  @override
  State<DonatePage> createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  bool? foodCheckboxValue = false;
  bool? clothesCheckboxValue = false;
  bool? cashCheckboxValue = false;
  bool? necessitiesCheckboxValue = false;
  String? _dropdownValue = 'pickup';
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
                  setState(() {
                    foodCheckboxValue = value;
                  });
                }),
            CheckboxListTile(
                title: const Text("Clothes"),
                value: clothesCheckboxValue,
                onChanged: (bool? value) {
                  setState(() {
                    clothesCheckboxValue = value;
                  });
                }),
            CheckboxListTile(
                title: const Text("Cash"),
                value: cashCheckboxValue,
                onChanged: (bool? value) {
                  setState(() {
                    cashCheckboxValue = value;
                  });
                }),
            CheckboxListTile(
                title: const Text("Necessities"),
                value: necessitiesCheckboxValue,
                onChanged: (bool? value) {
                  setState(() {
                    necessitiesCheckboxValue = value;
                  });
                }),
            DropdownButton(
                items: const [
                  DropdownMenuItem(child: Text("Pick-up"), value: "pickup"),
                  DropdownMenuItem(child: Text("Drop-off"), value: "dropoff"),
                ],
                value: _dropdownValue,
                onChanged: (String? value) {
                  setState(() {
                    _dropdownValue = value;
                  });
                }),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await context.read<UserAuthProvider>().authService.addDonation(foodCheckboxValue!, clothesCheckboxValue!, cashCheckboxValue!, necessitiesCheckboxValue!, _dropdownValue!);
              },
              child: Text('Donate'),
            ),
            // Widget to display donors
          ],
        ),
      ),
    );
  }
}
