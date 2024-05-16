import 'package:flutter/material.dart';

class DonationDetailsPage extends StatelessWidget {
  const DonationDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donation Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Donation Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('Donor: John Doe'),
            Text('Amount: \$100'),
            Text('Date: May 16, 2024'),
            //dummy data only, add when necessary
            SizedBox(height: 20),
            Text(
              'Status:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                //button for updating something
              },
              child: Text('Update Status'),
            ),
          ],
        ),
      ),
    );
  }
}
