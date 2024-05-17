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

  Future<String?> signUpDonor(String name, String username, String password, String address, String contactNo) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: '${username.toLowerCase().replaceAll(' ', '')}@example.com',
        password: password,
      );

      await firestore.collection('donors').doc(userCredential.user!.uid).set({
        'name': name,
        'username': username,
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

  Future<String?> signUpOrganization(String organizationName) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: '${organizationName.toLowerCase().replaceAll(' ', '')}@example.com',
        password: 'organizationPassword',
      );

      String uid = userCredential.user!.uid;

      await firestore.collection('organizations').doc(uid).set({
        'organizationName': organizationName,
        'isApproved': false,
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      UserCredential credentials = await auth.signInWithEmailAndPassword(email: email, password: password);
      print(credentials);
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
