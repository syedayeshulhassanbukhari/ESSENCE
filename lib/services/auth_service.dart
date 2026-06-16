import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';

class AuthService {
  AuthService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Create or update user profile in Firestore after auth sign-up.
  Future<void> syncUserToFirestore({
    required User authUser,
    required String displayName,
  }) async {
    try {
      final profile = UserProfile(
        uid: authUser.uid,
        email: authUser.email ?? '',
        displayName: displayName.isNotEmpty
            ? displayName
            : (authUser.displayName ?? 'User'),
        photoUrl: authUser.photoURL ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _usersCollection.doc(authUser.uid).set(
        profile.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      // Log error but don't throw - auth should still proceed
      print('Warning: Failed to sync user to Firestore: $e');
    }
  }

  /// Fetch user profile from Firestore.
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final snapshot = await _usersCollection.doc(uid).get();
      if (snapshot.exists) {
        return UserProfile.fromSnapshot(snapshot);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  /// Update user profile in Firestore.
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (displayName != null && displayName.isNotEmpty) {
        updates['displayName'] = displayName;
      }
      if (photoUrl != null && photoUrl.isNotEmpty) {
        updates['photoUrl'] = photoUrl;
      }

      await _usersCollection.doc(uid).update(updates);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Delete user profile from Firestore (if user is deleted).
  Future<void> deleteUserProfile(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }
}
