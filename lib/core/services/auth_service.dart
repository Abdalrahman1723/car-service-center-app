import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum UserRole { admin, supervisor, inventory }

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get user role from Firestore
  Future<UserRole?> getUserRole(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final role = doc.data()?['role'] as String?;
        switch (role) {
          case 'admin':
            return UserRole.admin;
          case 'supervisor':
            return UserRole.supervisor;
          case 'inventory':
            return UserRole.inventory;
          default:
            return null;
        }
      }
      return null;
    } catch (e) {
      log('Error getting user role: $e');
      return null;
    }
  }

  // Login with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Create user with role
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
    UserRole role,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Save user role to Firestore
    await _firestore.collection('users').doc(credential.user!.uid).set({
      'email': email,
      'role': role.name,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  // Update user role
  Future<void> updateUserRole(String userId, UserRole role) async {
    await _firestore.collection('users').doc(userId).update({
      'role': role.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }
}
