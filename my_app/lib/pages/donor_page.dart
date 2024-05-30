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
              // await context.read<UserAuthProvider>().signOut();
              // Navigator.pushAndRemoveUntil(
              //   context,
              //   MaterialPageRoute(builder: (context) => SignInPage()),
              //   (Route<dynamic> route) => false,
              // );
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
            Expanded(child: OrganizationsList(donorData?['name'], donorData?['email'])), // Widget to display organizations
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
              trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DonatePage(donorName: donorName, donorEmail: donorEmail, orgEmail : data['email'])));
                      },
                      child: Text('Donate'),
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

Future<String?> _getCurrentUserEmail() async {
  User? user = FirebaseAuth.instance.currentUser;
  return user?.email;
}
// class DonorPage extends StatelessWidget {

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Donor Dashboard'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.person),
//             onPressed: () async {
//               // await context.read<UserAuthProvider>().signOut();
//               // Navigator.pushAndRemoveUntil(
//               //   context,
//               //   MaterialPageRoute(builder: (context) => SignInPage()),
//               //   (Route<dynamic> route) => false,
//               // );
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () async {
//               await context.read<UserAuthProvider>().signOut();
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (context) => SignInPage()),
//                 (Route<dynamic> route) => false,
//               );
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Organizations:',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             Expanded(child: OrganizationsList()), // Widget to display organizations
//             SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class OrganizationsList extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: FirebaseFirestore.instance.collection('organizations').snapshots(),
//       builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (snapshot.hasError) {
//           return Text('Error: ${snapshot.error}');
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return CircularProgressIndicator();
//         }

//         return ListView(
//           shrinkWrap: true,
//           children: snapshot.data!.docs.map((doc) {
//             Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//             bool isApproved = data['isApproved'] ?? false;
//             return ListTile(
//               title: Text(data['organizationName']),
//               trailing: ElevatedButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => DonatePage(userEmail: email, orgEmail: data['email'])));
//                       },
//                       child: Text('Donate'),
//                     ),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }

//   Future<void> approveOrganization(String docId) async {
//     try {
//       await FirebaseFirestore.instance.collection('organizations').doc(docId).update({
//         'isApproved': true, // Update isApproved to true when approved
//       });
//       print('Organization approved successfully');
//     } catch (e) {
//       print('Error approving organization: $e');
//     }
//   }

  
// }

