import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:telephony/telephony.dart';
import 'package:week9_authentication/providers/auth_provider.dart';

class DonationDetailsPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic>? donData;

  const DonationDetailsPage(
      {Key? key, required this.docId, required this.donData})
      : super(key: key);

  @override
  _DonationDetailsPageState createState() => _DonationDetailsPageState();
}

class _DonationDetailsPageState extends State<DonationDetailsPage> {
  Map<String, dynamic>? userData;
  bool _isLoading = true;
  User? org;
  String selectedStatus = 'Pending';
  String? selectedDriveId;
  List<DocumentSnapshot> donationDrives = [];
  final List<String> _statusOptions = [
    'Pending',
    'Confirmed',
    'Scheduled for Pick-up',
    'Complete',
    'Canceled',
  ];
  final Telephony telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();
    if (widget.donData != null && widget.donData!['email'] != null) {
      _fetchUserData();
      org = context.read<UserAuthProvider>().user;
    } else {
      setState(() {
        _isLoading = false;
      });
    }
    selectedStatus = widget.donData!['status'];
    _loadDonationDrives();
  }

  Future<void> _fetchUserData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("donors")
          .where('email', isEqualTo: widget.donData!['email'])
          .limit(1)
          .get();

      setState(() {
        userData = snapshot.docs.isNotEmpty
            ? snapshot.docs.first.data() as Map<String, dynamic>
            : null;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> changeStatus(String docId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('donations')
          .doc(docId)
          .update({
        'status': status,
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _loadDonationDrives() async {
    QuerySnapshot drivesSnapshot = await FirebaseFirestore.instance
        .collection('donation_drives')
        .where('orgEmail', isEqualTo: org!.email!)
        .get();
    setState(() {
      donationDrives =
          (drivesSnapshot.docs.isNotEmpty ? drivesSnapshot.docs : []);
    });
    print('$donationDrives DASFJKHASDKLDASKLJASDJLK');
  }

  Future<void> _linkToDrive() async {
    if (selectedDriveId != null) {
      try {
        DocumentSnapshot driveSnapshot = await FirebaseFirestore.instance
            .collection('donation_drives')
            .doc(selectedDriveId)
            .get();
        String driveTitle = driveSnapshot['title'];
        await FirebaseFirestore.instance
            .collection('donation_drives')
            .doc(selectedDriveId)
            .update({
          'linked_donations': FieldValue.arrayUnion([widget.docId]),
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Donation linked to drive successfully')));
        _sendSms(driveTitle);
      } catch (e) {
        print('Error linking donation to drive: $e');
      }
    }
  }

  void _sendSms(String driveTitle) async {
    String? phoneNumber = userData?['contactNo'];
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final bool? result = await telephony.requestPhoneAndSmsPermissions;
      if (result != null && result) {
        telephony.sendSms(
          to: phoneNumber,
          message:
              'AUTOSMS: Your donation has been successfully linked to the drive: $driveTitle!',
        );
      } else {
        print('Permission to send SMS not granted.');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Permission to send SMS not granted.')));
      }
    } else {
      print('User phone number is not available.');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User phone number is not available.')));
    }
  }

  List<String> _getCategories() {
    List<String> categories = [];
    if (widget.donData!['cash'] == true) {
      categories.add('Cash');
    }
    if (widget.donData!['clothes'] == true) {
      categories.add('Clothes');
    }
    if (widget.donData!['food'] == true) {
      categories.add('Food');
    }
    if (widget.donData!['necessities'] == true) {
      categories.add('Necessities');
    }
    return categories;
  }

  @override
  Widget build(BuildContext context) {
    // Format the date for display
    String formattedDate = 'Loading...';
    String formattedTime = 'Loading...';
    if (widget.donData != null && widget.donData!['dateandTime'] is Timestamp) {
      DateTime donationDate =
          (widget.donData!['dateandTime'] as Timestamp).toDate();
      formattedDate = DateFormat.yMMMd().format(donationDate);
      formattedTime = DateFormat.jm().format(donationDate);
    }

    List<String> categories = _getCategories();

    return Scaffold(
      appBar: AppBar(
        title: Text('Donation Details'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Donors Information',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(Icons.person,
                                  color: Colors.teal, size: 26),
                              const SizedBox(width: 10),
                              Text(userData!['name'],
                                  style: const TextStyle(fontSize: 18))
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(Icons.mail,
                                  color: Colors.teal, size: 26),
                              const SizedBox(width: 10),
                              Text(userData!['email'],
                                  style: const TextStyle(fontSize: 18))
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(Icons.phone,
                                  color: Colors.teal, size: 26),
                              const SizedBox(width: 10),
                              Text(userData!['contactNo'],
                                  style: const TextStyle(fontSize: 18))
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.teal, size: 26),
                              const SizedBox(width: 10),
                              Text(userData!['address'],
                                  style: const TextStyle(fontSize: 18))
                            ],
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Donation Information',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                "Category: ",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal),
                              ),
                              Expanded(
                                child: Text(categories.join(', '),
                                    style: const TextStyle(fontSize: 18)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                "Items are for: ",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal),
                              ),
                              Text(widget.donData!['modeofDelivery'],
                                  style: const TextStyle(fontSize: 18))
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                "Weight: ",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal),
                              ),
                              Text('${widget.donData!['weight'].toString()}kg',
                                  style: const TextStyle(fontSize: 18))
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                "Date: ",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal),
                              ),
                              Text(formattedDate,
                                  style: const TextStyle(fontSize: 18))
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                "Time: ",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal),
                              ),
                              Text(formattedTime,
                                  style: const TextStyle(fontSize: 18))
                            ],
                          ),
                          const SizedBox(height: 5),
                          if (widget.donData!['modeofDelivery'] == 'Pick-up')
                            const Text("For pick-up deliveries:"),
                          if (widget.donData!['modeofDelivery'] == 'Pick-up')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  "Address: ",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal),
                                ),
                                Text(widget.donData!['address'],
                                    style: const TextStyle(fontSize: 18))
                              ],
                            ),
                          const SizedBox(height: 5),
                          if (widget.donData!['modeofDelivery'] == 'Pick-up')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  "Contact Number: ",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal),
                                ),
                                Text(widget.donData!['contactNo'],
                                    style: const TextStyle(fontSize: 18))
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Status:',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedStatus,
                              items: _statusOptions.map((String status) {
                                return DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(
                                    status,
                                    style: TextStyle(fontSize: 18),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedStatus = newValue!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedDriveId,
                    hint: Text('Select Donation Drive'),
                    items: donationDrives.map((drive) {
                      return DropdownMenuItem<String>(
                        value: drive.id,
                        child: Text(drive['title']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDriveId = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _linkToDrive,
                    child: Text('Link to Drive'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        changeStatus(widget.docId, selectedStatus);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Status updated!')));
                        // Handle the status update logic here
                        print('Status updated to $selectedStatus');
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.teal, // Text color
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Update Status',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
