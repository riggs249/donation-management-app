
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:week9_authentication/pages/admin_page.dart';
import 'package:week9_authentication/pages/donations_details_page.dart';
import 'package:provider/provider.dart';
import 'package:week9_authentication/pages/signin_page.dart';
import '../providers/auth_provider.dart';

class OrganizationHomePage extends StatefulWidget {
  const OrganizationHomePage({super.key});

  @override
  State<OrganizationHomePage> createState() => _OrganizationHomePageState();
}
  
class _OrganizationHomePageState extends State<OrganizationHomePage> {

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer,
      appBar: AppBar(
        title: Text('Organization Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'List of Donations',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 15, //sample palang dummy data
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
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
      ),
    );
    
  }
  Drawer get drawer => Drawer(
          child: ListView(padding: EdgeInsets.zero, children: [
        const DrawerHeader(
  child: Text("Organization Page", style: TextStyle(fontSize: 24)),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.blue, Colors.green], // Define the colors for the gradient
      begin: Alignment.topLeft, // Define the start point of the gradient
      end: Alignment.bottomRight, // Define the end point of the gradient
    ),
  ),
),

        ListTile(
          title: const Text('Details'),
          onTap: () {
          //   Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => UserDetailsPage(details: userData)));
          },
        ),
        ListTile(
          title: const Text('Todo List'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, "/");
          },
        ),
        ListTile(
          title: const Text('Logout'),
          onTap: () {
            context.read<UserAuthProvider>().signOut();
          Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SignInPage()),
                (Route<dynamic> route) => false,
              );
          },
        ),
        ListTile(
          title: const Text('Admin page'),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AdminPage()));
          },
        ),
      ]));
}
