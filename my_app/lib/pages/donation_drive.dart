import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DonationDrivesPage extends StatefulWidget {
  final String orgEmail;

  const DonationDrivesPage({Key? key, required this.orgEmail})
      : super(key: key);

  @override
  _DonationDrivesPageState createState() => _DonationDrivesPageState();
}

class _DonationDrivesPageState extends State<DonationDrivesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Drives',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('donation_drives')
            .where('orgEmail', isEqualTo: widget.orgEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var drives = snapshot.data!.docs;

          return ListView.builder(
            itemCount: drives.length,
            itemBuilder: (context, index) {
              var drive = drives[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(drive['title'],
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal)),
                  subtitle: Text(drive['description']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.teal),
                        onPressed: () {
                          // Navigate to update page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditDonationDrivePage(driveId: drive.id),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _firestore
                              .collection('donation_drives')
                              .doc(drive.id)
                              .delete();
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to details page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DonationDriveDetailsPage(driveId: drive.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CreateDonationDrivePage(orgEmail: widget.orgEmail),
            ),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class CreateDonationDrivePage extends StatefulWidget {
  final String orgEmail;

  const CreateDonationDrivePage({Key? key, required this.orgEmail})
      : super(key: key);

  @override
  _CreateDonationDrivePageState createState() =>
      _CreateDonationDrivePageState();
}

class _CreateDonationDrivePageState extends State<CreateDonationDrivePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _createDonationDrive() async {
    try {
      await _firestore.collection('donation_drives').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'orgEmail': widget.orgEmail,
      });
      Navigator.pop(context);
    } catch (e) {
      print('Error creating donation drive: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Donation Drive'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createDonationDrive,
              child: const Text('Create'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditDonationDrivePage extends StatefulWidget {
  final String driveId;

  const EditDonationDrivePage({Key? key, required this.driveId})
      : super(key: key);

  @override
  _EditDonationDrivePageState createState() => _EditDonationDrivePageState();
}

class _EditDonationDrivePageState extends State<EditDonationDrivePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadDriveData();
  }

  Future<void> _loadDriveData() async {
    DocumentSnapshot drive = await _firestore
        .collection('donation_drives')
        .doc(widget.driveId)
        .get();
    _titleController.text = drive['title'];
    _descriptionController.text = drive['description'];
  }

  Future<void> _updateDonationDrive() async {
    try {
      await _firestore
          .collection('donation_drives')
          .doc(widget.driveId)
          .update({
        'title': _titleController.text,
        'description': _descriptionController.text,
      });
      Navigator.pop(context);
    } catch (e) {
      print('Error updating donation drive: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Donation Drive'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateDonationDrive,
              child: Text('Update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DonationDriveDetailsPage extends StatefulWidget {
  final String driveId;

  const DonationDriveDetailsPage({Key? key, required this.driveId})
      : super(key: key);

  @override
  _DonationDriveDetailsPageState createState() =>
      _DonationDriveDetailsPageState();
}

class _DonationDriveDetailsPageState extends State<DonationDriveDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? driveData;
  List<DocumentSnapshot> linkedDonations = [];
  List<File> images = [];
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    _loadDriveData();
    _loadLinkedDonations();
  }

  Future<void> _loadDriveData() async {
    DocumentSnapshot drive = await _firestore
        .collection('donation_drives')
        .doc(widget.driveId)
        .get();
    setState(() {
      driveData = drive.data() as Map<String, dynamic>;
    });
  }

  Future<void> _loadLinkedDonations() async {
    DocumentSnapshot drive = await _firestore
        .collection('donation_drives')
        .doc(widget.driveId)
        .get();
    List<dynamic> linkedDonationIds = drive['linked_donations'] ?? [];
    if (linkedDonationIds.isNotEmpty) {
      QuerySnapshot donationsSnapshot = await _firestore
          .collection('donations')
          .where(FieldPath.documentId, whereIn: linkedDonationIds)
          .get();
      setState(() {
        linkedDonations = donationsSnapshot.docs;
      });
    }
  }

  Future<void> _addPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        images.add(imageFile);
      });

      // Upload image to Firebase Storage
      try {
        final storageRef = FirebaseStorage.instance.ref().child(
            'donation_drives/${widget.driveId}/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = storageRef.putFile(imageFile);
        final snapshot = await uploadTask.whenComplete(() {});
        final imageUrl = await snapshot.ref.getDownloadURL();

        // Store image URL in Firestore
        await _firestore
            .collection('donation_drives')
            .doc(widget.driveId)
            .update({
          'photos': FieldValue.arrayUnion([imageUrl])
        });

        setState(() {
          imageUrls.add(imageUrl);
        });
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donation Drive Details'),
        backgroundColor: Colors.teal,
      ),
      body: driveData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(driveData!['title'],
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal)),
                  SizedBox(height: 10),
                  Text(driveData!['description'],
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  Text('Linked Donations:',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal)),
                  SizedBox(height: 10),
                  if (linkedDonations.isNotEmpty)
                    for (var donation in linkedDonations)
                      ListTile(
                        title: Text('Donation ID: ${donation.id}'),
                        subtitle: Text('Email: ${donation['email']}'),
                      ),
                  if (linkedDonations.isEmpty)
                    Text('No donations linked to this drive yet.'),
                  SizedBox(height: 20),
                  Text('Photos:',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal)),
                  SizedBox(height: 10),
                  if (driveData!['photos'] != null)
                    for (String photoUrl in driveData!['photos'])
                      Image.network(photoUrl),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addPhoto,
                    child: Text('Add Photo'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  ),
                ],
              ),
            ),
    );
  }
}
