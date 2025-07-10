import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:holbegram/models/user.dart';

class AuthMethode {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> login({
    required String email,
    required String password,
  }) async {
    String res = 'Some error occurred';
    try {
      if (email.isEmpty || password.isEmpty) {
        res = 'Please fill all the fields';
      } else {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = 'success';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    Uint8List? file,
  }) async {
    String res = 'Some error occurred';
    try {
      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        res = 'Please fill all the fields';
      } else {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password);
        User? user = userCredential.user;

        String photoUrl = ''; // Placeholder for now

        Users newUser = Users(
          uid: user!.uid,
          email: email,
          username: username,
          bio: '', // Assuming bio is empty for now
          photoUrl: photoUrl,
          followers: [],
          following: [],
          posts: [],
          saved: [],
          searchKey: username.substring(0, 1).toUpperCase(),
        );

        await _firestore
            .collection("users")
            .doc(user.uid)
            .set(newUser.toJson());
        res = 'success';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<Users> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();
    return Users.fromSnap(snap);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
