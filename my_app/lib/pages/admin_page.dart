import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'signin_page.dart';
import '../providers/auth_provider.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
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
              'Organizations:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(child: OrganizationsList()), // Widget to display organizations
            SizedBox(height: 20),
            Text(
              'Donors:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(child: DonorsList()), // Widget to display donors
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
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        return ListView(
          shrinkWrap: true,
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            bool isApproved = data['isApproved'] ?? false;
            return ListTile(
              title: Text(data['organizationName']),
              subtitle: Text('Status: ${isApproved ? 'Approved' : 'Pending'}'),
              trailing: isApproved
                  ? null // Don't show button if already approved
                  : ElevatedButton(
                      onPressed: () {
                        approveOrganization(doc.id);
                      },
                      child: Text('Approve'),
                    ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> approveOrganization(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('organizations').doc(docId).update({
        'isApproved': true, // Update isApproved to true when approved
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
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        return ListView(
          shrinkWrap: true,
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
    return ExpansionTile(
      title: Text(data['name']),
      children: [
        ListTile(
          title: Text('Username: ${data['username']}'),
        ),
        ListTile(
          title: Text('Address: ${data['address']}'),
        ),
        ListTile(
          title: Text('Contact Number: ${data['contactNo']}'),
        ),
      ],
    );
  }
}
