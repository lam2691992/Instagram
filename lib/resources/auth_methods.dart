import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:instagram_clone/models/user.dart' as model;
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/utils/utils.dart';

class AuthMethods {
  static const String _usersCollection = 'users';
  static const String _profilePicsFolder = 'profilePics';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper method
  Future<model.User> getUserDetails() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not logged in');

    final snap = await _firestore
        .collection(_usersCollection)
        .doc(currentUser.uid)
        .get();

    if (!snap.exists) throw Exception('User data not found');
    return model.User.fromSnap(snap);
  }

  // sign up user
  Future<String> signupUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    try {
      _validateInputs([email, password, username, bio], file);

      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final photoUrl = await StorageMethods()
          .uploadImageToStorage(_profilePicsFolder, file, false);

      await _saveUserData(
        uid: cred.user!.uid,
        email: email,
        username: username,
        bio: bio,
        photoUrl: photoUrl,
      );

      return 'success';
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthError(e);
    } on FirebaseException catch (e) {
      return 'Firestore error: ${e.message}';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  // login user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      _validateInputs([email, password]);

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'success';
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthError(e);
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  // log out
  Future<void> signOut(BuildContext context) async {
  await _auth.signOut();
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const LoginScreen()),
    (route) => false,
  );
}


  // Validate input
  void _validateInputs(List<String> inputs, [Uint8List? file]) {
    if (inputs.any((input) => input.isEmpty)) {
      throw Exception('All fields are required');
    }
    if (file != null && file.isEmpty) {
      throw Exception('Profile image is required');
    }
  }

  // handle firebase
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Invalid email or password';
      case 'email-already-in-use':
        return 'Email already registered';
      case 'weak-password':
        return 'Password is too weak';
      default:
        return 'Authentication error: ${e.message}';
    }
  }

  // save user
  Future<void> _saveUserData({
    required String uid,
    required String email,
    required String username,
    required String bio,
    required String photoUrl,
  }) async {
    await _firestore.runTransaction((transaction) async {
      final userDoc = _firestore.collection(_usersCollection).doc(uid);

      final user = model.User(
        username: username,
        uid: uid,
        email: email,
        bio: bio,
        followers: [],
        following: [],
        photoUrl: photoUrl,
      );

      transaction.set(userDoc, user.toJson());
    });
  }
}
