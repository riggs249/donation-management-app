import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthApi {
  late FirebaseAuth auth;
  late FirebaseFirestore firestore;

  FirebaseAuthApi() {
    auth = FirebaseAuth.instance;
    firestore = FirebaseFirestore.instance;
  }

  Stream<User?> fetchUser() {
    return auth.authStateChanges();
  }

  User? getUser() {
    return auth.currentUser;
  }

  Future<String?> signUpDonor(String name, String email, String password, String address, String contactNo) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await firestore.collection('donors').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'address': address,
        'contactNo': contactNo,
      });

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String?> signUpOrganization(String organizationName, String email, String password, String address, String contactNo) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      await firestore.collection('organizations').doc(uid).set({
        'organizationName': organizationName,
        'email': email,
        'address': address,
        'contactNo': contactNo,
        'isApproved': false,
        'isOpen': false,
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String?> addDonation(String email, String orgEmail, String address, String weight, DateTime dateandTime, String contactNo, bool food, bool clothes, bool cash, bool necessities, String pickupOrDropoff) async {
    try {
      await firestore.collection('donations')
      .add({
        'name': "john doe",
        'email': email,
        'orgEmail': orgEmail,
        'address': address,
        'contactNo': contactNo,
        'category': "Category/ies",
        'weight': weight,
        'dateandTime': dateandTime,
        'food': food,
        'clothes': clothes,
        'cash': cash,
        'necessities': necessities,
        'modeofDelivery': pickupOrDropoff,
        'status': "Pending"
      });
      return "succes";
    } on FirebaseException catch (e) {
      return "failed";
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      UserCredential credentials = await auth.signInWithEmailAndPassword(email: email, password: password);
      String uid = credentials.user!.uid;

      DocumentSnapshot donorDoc = await firestore.collection('donors').doc(uid).get();
      if (donorDoc.exists) {
        return "donor";
      }

      DocumentSnapshot orgDoc = await firestore.collection('organizations').doc(uid).get();
      if (orgDoc.exists) {
        bool isApproved = orgDoc.get('isApproved');
        if (isApproved) {
          return "organization";
        } else {
          return "not-approved";
        }
      }

      return "Success";
    } on FirebaseAuthException catch(e) {
      return e.code;
    } catch(e) {
      return 'Error: $e';
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  
}
