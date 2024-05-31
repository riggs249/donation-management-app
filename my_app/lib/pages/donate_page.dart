import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:provider/provider.dart';
import 'signin_page.dart';
import '../providers/auth_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

class DonatePage extends StatefulWidget {
  final String? donorName;
  final String? donorEmail;
  final String? orgEmail;
  const DonatePage({super.key, this.donorName, this.donorEmail, this.orgEmail});

  @override
  State<DonatePage> createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  final _formKey = GlobalKey<FormState>();
  bool? foodCheckboxValue = false;
  bool? clothesCheckboxValue = false;
  bool? cashCheckboxValue = false;
  bool? necessitiesCheckboxValue = false;
  DateTime? dateandTime;
  DateTime? start = DateTime.now();
  DateTime? end = DateTime(DateTime.now().year+2);
  String? _dropdownValue = 'Pick-up';
  String? weight;
  String? address;
  String? contactNo;
  Uint8List? imageFile;
  ScreenshotController screenshotController = ScreenshotController(); 
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
      body: SingleChildScrollView(child: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Form(
          key: _formKey,
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
                    DropdownMenuItem(child: Text("Pick-up"), value: "Pick-up"),
                    DropdownMenuItem(child: Text("Drop-off"), value: "Drop-off"),
                  ],
                  value: _dropdownValue,
                  onChanged: (String? value) {
                    setState(() {
                      _dropdownValue = value;
                    });
                  }),
              _dropdownValue == "Pick-up" ? TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Pick-up address",
                  hintText: "Input address"
                ),
                  onSaved: (value) {
                    setState(() {
                      address = value;
                    }); 
                  },
                  validator: (value) {
                    if(value == null || value.isEmpty) {
                      return "please enter address";
                    } return null;
                  },
              ) : SizedBox(height: 0),
              _dropdownValue == "Pick-up" ? TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Contact no.",
                  hintText: "Input contact no."
                ),
                  onSaved: (value) {
                    setState(() {
                      contactNo = value;
                    }); 
                  },
                  validator: (value) {
                    if(value == null || value.isEmpty) {
                      return "please enter contact no";
                    } return null;
                  },
              ) : SizedBox(height: 0),
              _dropdownValue == "Drop-off" ? Screenshot(controller: screenshotController, child: QrImageView(
                data: '${widget.donorEmail}${widget.orgEmail}',
                version: QrVersions.auto,
                size: 200.0
              )) : SizedBox(height: 0),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Date",
                  filled: true,
                  prefixIcon: Icon(Icons.calendar_month_outlined),
                  enabledBorder: OutlineInputBorder()
                ),
                readOnly: true,
                onTap: () {
                  
                  showDateTimePicker(context: context).then((result) {
                    setState(() {
                      dateandTime = result;
                    });
                  });
                },
                
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Weight",
                  hintText: "Input weight"
                ),
                onSaved: (value) {
                  setState(() {
                    weight = value;
                  });
                  weight=value;
                },
                validator: (value) {
                    if(value == null || value.isEmpty) {
                      return "please enter address";
                    } return null;
                  },
              ),
              SizedBox(height: 20),
              //Input
              ElevatedButton(
                onPressed: () async {
                  if(_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                  }
                  await context.read<UserAuthProvider>().authService.addDonation(widget.donorName!, widget.donorEmail!, widget.orgEmail!, address!, weight!, dateandTime!, contactNo!, foodCheckboxValue!, clothesCheckboxValue!, cashCheckboxValue!, necessitiesCheckboxValue!, _dropdownValue!);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Donation sent!")));
                  screenshotController.capture().then((Uint8List? image) {
                      //Capture Done
                      setState(() {
                          imageFile = image;
                      });
                  }).catchError((onError) {
                      print(onError);
                  });
                  await ImageGallerySaver.saveImage(imageFile!);
                },
                child: Text('Donate'),
              ),

              // Widget to display donors
            ],

          ),
      ),
    )));
  }

  Future<DateTime?> showDateTimePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  initialDate ??= DateTime.now();
  firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
  lastDate ??= firstDate.add(const Duration(days: 365 * 200));

  final DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
  );

  if (selectedDate == null) return null;

  if (!context.mounted) return selectedDate;

  final TimeOfDay? selectedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initialDate),
  );

  return selectedTime == null
      ? selectedDate
      : DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
}

}
