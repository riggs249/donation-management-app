import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:week9_authentication/pages/admin_page.dart';
import 'package:week9_authentication/pages/donations_details_page.dart';
import 'package:week9_authentication/pages/signin_page.dart';
import '../providers/auth_provider.dart';

class OrganizationHomePage extends StatefulWidget {
  const OrganizationHomePage({super.key});

  @override
  State<OrganizationHomePage> createState() => _OrganizationHomePageState();
}

class _OrganizationHomePageState extends State<OrganizationHomePage> {
  int _selectedIndex = 0;
  User? org;
  Map<String, dynamic>? orgData;
  String? docId;

  @override
  void initState() {
    super.initState();
    org = context.read<UserAuthProvider>().user;
    _fetchUserData();
  }

  

  Future<void> _fetchUserData() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("organizations")
        .where('email', isEqualTo: org!.email!)
        .get();

    setState(() {
      orgData = snapshot.docs.isNotEmpty
          ? snapshot.docs.first.data() as Map<String, dynamic>
          : null;
      docId = snapshot.docs.first.id;
    });
          print(snapshot.docs.first.id);
  }

  

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetOptions = [
      DonationListPage(),
      AdminPage(),
      ProfilePage(orgData: orgData, docId: docId),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Organization Home'),
        backgroundColor: Colors.teal,
        elevation: 4.0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Add notification logic here
            },
          ),
        ],
      ),
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Donations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10.0,
        onTap: (index) {
          if (index == 3) {
            context.read<UserAuthProvider>().signOut();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => SignInPage()),
              (Route<dynamic> route) => false,
            );
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
      ),
    );
  }
}

class DonationListPage extends StatelessWidget {
  const DonationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'List of Donations',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: 15, // Sample placeholder data
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.favorite, color: Colors.white),
                    ),
                    title: Text(
                      'Donation ${index + 1}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Donation details...'),
                    onTap: () {
                      // Navigate to donation details page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DonationDetailsPage(),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

  Future<void> tickStatus(String docId, bool status) async {
    try {
      if(status) {
      await FirebaseFirestore.instance.collection('organizations').doc(docId).update({
        'isOpen': true, // Update isOpen to true when ticked
      });
      }else {
      await FirebaseFirestore.instance.collection('organizations').doc(docId).update({
        'isOpen': false, // Update isOpen to false 
      });
      }
    } catch (e) {
      print('Error approving organization: $e');
    }
  }

  bool _isChecked = false;


class ProfilePage extends StatefulWidget {
  final Map<String, dynamic>? orgData;
  final String? docId;

  const ProfilePage({Key? key, this.orgData, this.docId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    if (widget.orgData == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Organization Profile',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.business, color: Colors.teal, size: 30),
                      SizedBox(width: 10),
                      Text(
                        widget.orgData!['organizationName'] ?? 'No Name',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.email, color: Colors.teal, size: 20),
                      SizedBox(width: 10),
                      Text(
                        widget.orgData!['email'] ?? 'No Email',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.teal, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.orgData!['address'] ?? 'No Address',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.teal, size: 20),
                      SizedBox(width: 10),
                      Text(
                        widget.orgData!['contactNo'] ?? 'No Phone',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                    Transform.translate(
                      offset: Offset(-5.0, 0.0), // Apply negative horizontal offset
                      child: Checkbox(
                        value: widget.orgData!['isOpen'],
                        onChanged: (bool? newValue) {
                          setState(() {
                            widget.orgData!['isOpen'] = newValue ?? false;
                          });
                          tickStatus(widget.docId!, widget.orgData!['isOpen']);
                        },
                        activeColor: Colors.teal, // Set the color of the checkbox to teal
                      ),
                    ),
                      Text(
                        widget.orgData!['isOpen'] ? 'Donation Status (Open)' : 'Donation Status (Closed)',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'About the Organization',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.orgData!['about'] ?? 'No description for this organization.'}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

