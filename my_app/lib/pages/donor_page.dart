import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './donate_page.dart';
import 'signin_page.dart';
import '../providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonorPage extends StatefulWidget {
  const DonorPage({super.key});

  @override
  State<DonorPage> createState() => _DonorPageState();
}

class _DonorPageState extends State<DonorPage> {
  User? donor;
  Map<String, dynamic>? donorData;
  String? docId;

  void initState() {
    super.initState();
    donor = context.read<UserAuthProvider>().user;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("donors")
        .where('email', isEqualTo: donor!.email!)
        .get();

    setState(() {
      donorData = snapshot.docs.isNotEmpty
          ? snapshot.docs.first.data() as Map<String, dynamic>
          : null;
      docId = snapshot.docs.first.id;
    });
    print(snapshot.docs.first.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donor: ${donorData?['name']}'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () async {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DonationListPage()));
            },
          ),
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
            Expanded(
                child: OrganizationsList(donorData?['name'],
                    donorData?['email'])), // Widget to display organizations
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class OrganizationsList extends StatelessWidget {
  OrganizationsList(this.donorName, this.donorEmail);
  String? donorName;
  String? donorEmail;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('organizations').snapshots(),
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
            bool isOpen = data['isOpen'] ?? false;
            return ListTile(
              title: Text(data['organizationName']),
              trailing: isOpen == true
                  ? ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DonatePage(
                                    donorName: donorName,
                                    donorEmail: donorEmail,
                                    orgEmail: data['email'])));
                      },
                      child: Text('Donate'),
                    )
                  : SizedBox(height: 0),
            );
          }).toList(),
        );
      },
    );
  }
}

Future<String?> _getCurrentUserEmail() async {
  User? user = FirebaseAuth.instance.currentUser;
  return user?.email;
}

class DonationListPage extends StatelessWidget {
  const DonationListPage({super.key});

  Future<String?> _getCurrentUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Donations"),
        
      ),
      body: FutureBuilder<String?>(
      future: _getCurrentUserEmail(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (userSnapshot.hasError) {
          return Text('Error: ${userSnapshot.error}');
        }

        String? userEmail = userSnapshot.data;

        if (userEmail == null) {
          return const Center(child: Text('No user logged in'));
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('donations')
              .where('email', isEqualTo: userEmail)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Stack(children: [
                const Center(child: Text('No donations found'))
              ]);
            }

            return Stack(children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'List of Donations',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data?.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> donData =
                              snapshot.data?.docs[index].data()
                                  as Map<String, dynamic>;
                          String docId = snapshot.data!.docs[index].id;
                          String status = donData['status'];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.purple,
                                child:
                                    Icon(Icons.favorite, color: Colors.white),
                              ),
                              title: Text(
                                'Donation ${index + 1}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('(${donData['status']}) Donated to ${donData['orgEmail']}'),
                              trailing: status == "Pending"
                                  ? ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          await FirebaseFirestore.instance.collection('donations').doc(docId).update({
                                            'status': "Canceled",
                                          });
                                        } catch (e) {

                                        }
                                      },
                                      child: Text('Cancel'),
                                    )
                                  : SizedBox(height: 0),
                              onTap: () {
                                // Navigate to donation details page
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => DonationDetailsPage(
                                //         docId: docId, donData: donData),
                                //   ),
                                // );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            ]);
          },
        );
      },
    )
    );
  }
}


