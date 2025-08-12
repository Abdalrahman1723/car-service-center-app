import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

class AuthHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?>? getUserRole() {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      // Fetch role synchronously from Firestore (cached if possible)
      // Note: This assumes the role is stored in the users collection
      final doc = _firestore.collection('users').doc(user.uid).get();
      return doc.then((snapshot) => snapshot.data()?['role'] as String?);
    } catch (e) {
      log('Error fetching user role: $e');
      return null;
    }
  }

  Future<bool> isManager() async {
    return getUserRole() == 'manager';
  }

  Future<bool> isSupervisor() async {
    final role = await getUserRole();
    return role == 'supervisor' || role == 'manager';
  }

  Future<bool> isInventoryWorker() async {
    final role = await getUserRole();
    return role == 'inventory_worker' || role == 'manager';
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      log('User signed out');
    } catch (e) {
      log('Sign out error: $e');
      throw Exception('Failed to sign out: $e');
    }
  }
}
