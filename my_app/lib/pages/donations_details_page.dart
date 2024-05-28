import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
  String selectedStatus = 'Pending';

  final List<String> _statusOptions = [
    'Pending',
    'Confirmed',
    'Scheduled for Pick-up',
    'Complete',
    'Canceled',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.donData != null && widget.donData!['email'] != null) {
      _fetchUserData();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
    selectedStatus = widget.donData!['status'];
  }

  Future<void> _fetchUserData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("donors")
          .where('email', isEqualTo: widget.donData!['email'])
          .limit(1) // Limit the results to 1
          .get();

      setState(() {
        userData = snapshot.docs.isNotEmpty
            ? snapshot.docs.first.data() as Map<String, dynamic>
            : null;
        _isLoading = false;
      });
      print(userData);
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Donation Details'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
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
                              // const Text(
                              //   "Donor: ",
                              //   style: TextStyle(
                              //       fontSize: 18, fontWeight: FontWeight.bold),
                              // ),
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
                              Text(widget.donData!['category'],
                                  style: const TextStyle(fontSize: 18))
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
                          // const SizedBox(height: 5),
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
