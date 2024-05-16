import 'package:flutter/material.dart';
import 'package:week9_authentication/pages/donations_details_page.dart';

class OrganizationHomePage extends StatelessWidget {
  const OrganizationHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                itemCount: 10, //sample palang dummy data
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
}
