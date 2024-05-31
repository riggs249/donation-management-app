import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'signin_page.dart';
import '../providers/auth_provider.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Admin Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          ),
          backgroundColor: Colors.teal,
          actions: [
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
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
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.teal.shade100,
            tabs: [
              Tab(text: 'Organizations'),
              Tab(text: 'Donors'),
              Tab(text: 'Donations'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OrganizationsList(),
            DonorsList(),
            DonationsList(),
          ],
        ),
      ),
    );
  }
}

class OrganizationsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('organizations').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: EdgeInsets.all(10),
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            bool isApproved = data['isApproved'] ?? false;
            return OrganizationTile(
              data: data,
              docId: doc.id,
              isApproved: isApproved,
            );
          }).toList(),
        );
      },
    );
  }
}

class OrganizationTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final bool isApproved;

  const OrganizationTile({
    required this.data,
    required this.docId,
    required this.isApproved,
  });

  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent), // Set divider color to transparent
        child: ExpansionTile(
          title: Text(data['organizationName'], style: TextStyle(color: Colors.teal)),
          subtitle: Text('Status: ${isApproved ? 'Approved' : 'Pending'}'),
          children: [
            ListTile(
              title: Text('Description: ${data['description']}'),
            ),
            ListTile(
              title: Text('Email: ${data['email']}'),
            ),
            ListTile(
              title: Text('Address: ${data['address']}'),
            ),
            ListTile(
              title: Text('Contact Number: ${data['contactNo']}'),
            ),
            if (!isApproved)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: () {
                  approveOrganization(docId);
                },
                child: const Text(
                  'Approve',
                  style: TextStyle(color: Colors.white), // Text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> approveOrganization(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('organizations').doc(docId).update({
        'isApproved': true,
      });
      print('Organization approved successfully');
    } catch (e) {
      print('Error approving organization: $e');
    }
  }
}

class DonorsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('donors').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: EdgeInsets.all(10),
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return DonorTile(data: data);
          }).toList(),
        );
      },
    );
  }
}

class DonorTile extends StatelessWidget {
  final Map<String, dynamic> data;

  const DonorTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent), // Set divider color to transparent
          child: ExpansionTile(
            title:Text(data['name'], style: TextStyle(color: Colors.teal)),
          children: [
            ListTile(
              title: Text('Email: ${data['email']}'),
            ),
            ListTile(
              title: Text('Address: ${data['address']}'),
            ),
            ListTile(
              title: Text('Contact Number: ${data['contactNo']}'),
            ),
          ],
        ),
      ),
    );
  }
}

class DonationsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('donations').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: EdgeInsets.all(10),
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return DonationTile(data: data);
          }).toList(),
        );
      },
    );
  }
}

class DonationTile extends StatelessWidget {
  final Map<String, dynamic> data;

  const DonationTile({required this.data});

  List<String> _getCategories() {
    List<String> categories = [];
    if (data['food'] == true) {
      categories.add('Food');
    }
    if (data['clothes'] == true) {
      categories.add('Clothes');
    }
    if (data['cash'] == true) {
      categories.add('Cash');
    }
    if (data['necessities'] == true) {
      categories.add('Necessities');
    }
    return categories;
  }

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = (data['dateandTime'] as Timestamp).toDate(); // Convert Timestamp to DateTime
    String formattedDateTime = DateFormat.yMMMd().add_jm().format(dateTime); // Format DateTime
    List<String> categories = _getCategories();

    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent), // Set divider color to transparent
          child: ExpansionTile(
            title:Text(data['name'], style: TextStyle(color: Colors.teal)),
            subtitle: Text('Status: ${data['status']}'),
            children: [
            ListTile(
              title: Text('Categories: ${categories.join(", ")}'),
            ),
            ListTile(
              title: Text('Donor Email: ${data['email']}'),
            ),
            ListTile(
              title: Text('Organization Email: ${data['orgEmail']}'),
            ),
            ListTile(
              title: Text('Weight: ${data['weight']}kg'),
            ),
            ListTile(
              title: Text('Mode of Delivery: ${data['modeofDelivery']}'),
            ),
            _buildDeliveryDetails(data['modeofDelivery'], data), // Render delivery details based on mode
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryDetails(String modeOfDelivery, Map<String, dynamic> data) {
    if (modeOfDelivery == 'Drop-off') {
      DateTime dateTime = (data['dateandTime'] as Timestamp).toDate();
      String formattedDateTime = DateFormat.yMMMd().add_jm().format(dateTime);
      return ListTile(
        title: Text('Drop-off Date: $formattedDateTime'),
      );
    } else if (modeOfDelivery == 'Pickup') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text('Contact Number: ${data['contactNo']}'),
          ),
          ListTile(
            title: Text('Address: ${data['address']}'),
          ),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
