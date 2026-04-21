import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Initialize GoogleSignIn standard way
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isGoogleInitialized = false;

  AuthService() {
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    if (_isGoogleInitialized) return;
    try {
      debugPrint('Initializing Google Sign In (Service Constructor)...');
      await _googleSignIn.initialize();
      _isGoogleInitialized = true;
    } catch (e) {
      debugPrint('Error initializing Google Sign In: $e');
    }
  }

  // Stream of auth state changes
  Stream<User?> get userStream => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential?> signUp({
    required String name,
    required String email,
    required String phone,
    required String gender,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        UserModel userModel = UserModel(
          uid: userCredential.user!.uid,
          name: name,
          email: email,
          phone: phone,
          gender: gender,
        );

        await _firestore.collection('users').doc(userCredential.user!.uid).set(userModel.toMap());
      }
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Login with email and password
  Future<UserCredential> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Ensure it's initialized before usage
      if (!_isGoogleInitialized) {
        await _initializeGoogleSignIn();
      }
      
      // In 7.x, the method to start auth is authenticate()
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return null;

      // In 7.x, get tokens from the account
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Note: idToken is usually sufficient for Firebase GoogleAuthProvider on Google
      // On web, accessToken might be null or handled specifically.
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          UserModel userModel = UserModel(
            uid: user.uid,
            name: user.displayName ?? '',
            email: user.email ?? '',
            phone: user.phoneNumber ?? '',
            gender: 'Not Specified',
          );
          await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
        }
      }
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
