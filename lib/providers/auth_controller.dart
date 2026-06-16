import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/auth_service.dart';

class AuthController {
  AuthController({FirebaseAuth? auth, AuthService? authService})
      : _auth = auth ?? FirebaseAuth.instance,
        _authService = authService ?? AuthService();

  final FirebaseAuth _auth;
  final AuthService _authService;

  Future<String?> signInWithGoogle() async {
    try {
      print('[AuthController] Attempting Google sign-in');
      final googleProvider = GoogleAuthProvider();
      UserCredential result;
      if (kIsWeb) {
        result = await _auth.signInWithPopup(googleProvider);
      } else {
        result = await _auth.signInWithProvider(googleProvider);
      }
      print('[AuthController] Google sign-in successful: ${result.user?.uid}');
      
      if (result.user != null) {
        print('[AuthController] Syncing Google user to Firestore...');
        await _authService.syncUserToFirestore(
          authUser: result.user!,
          displayName: result.user!.displayName ?? '',
        );
        print('[AuthController] Google user synced to Firestore');
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('[AuthController] Google sign-in error: ${e.code} - ${e.message}');
      return _mapFirebaseError(e);
    } catch (e) {
      print('[AuthController] Google sign-in exception: $e');
      return 'Something went wrong. Please try again.';
    }
  }

  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      print('[AuthController] Attempting email sign-in: $email');
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      print('[AuthController] Email sign-in successful: ${credential.user?.uid}');
      
      // Sync user to Firestore to ensure profile is up-to-date
      if (credential.user != null) {
        print('[AuthController] Syncing user to Firestore...');
        await _authService.syncUserToFirestore(
          authUser: credential.user!,
          displayName: credential.user!.displayName ?? '',
        );
        print('[AuthController] User synced to Firestore');
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('[AuthController] Email sign-in error: ${e.code} - ${e.message}');
      return _mapFirebaseError(e);
    } catch (e) {
      print('[AuthController] Email sign-in exception: $e');
      return 'Something went wrong. Please try again.';
    }
  }

  Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseError(e);
    } catch (_) {
      return 'Could not send reset email. Please try again.';
    }
  }

  Future<String?> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      print('[AuthController] Attempting email registration: $email');
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('[AuthController] Registration successful: ${credential.user?.uid}');

      await credential.user?.updateDisplayName(name);
      print('[AuthController] Display name updated');
      
      if (credential.user != null) {
        print('[AuthController] Syncing registered user to Firestore...');
        await _authService.syncUserToFirestore(
          authUser: credential.user!,
          displayName: name,
        );
        print('[AuthController] Registered user synced to Firestore');
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('[AuthController] Registration error: ${e.code} - ${e.message}');
      return _mapFirebaseError(e);
    } catch (e) {
      print('[AuthController] Registration exception: $e');
      return 'Something went wrong. Please try again.';
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'account-exists-with-different-credential':
        return 'Account exists with a different sign-in method.';
      case 'popup-closed-by-user':
        return 'Sign-in popup was closed before completing.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Password is too weak.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
