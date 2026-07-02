import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthException implements Exception {
  final String message;
  final String code;
  AuthException(this.message, this.code);
  @override
  String toString() => message;
}

class AuthService {
  AuthService._();
  static final _auth = FirebaseAuth.instance;
  static final _db   = FirebaseFirestore.instance;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  static User? get currentUser => _auth.currentUser;
  static String? get uid => _auth.currentUser?.uid;

  static Future<String> getUserRole(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return 'user';
      return doc.data()?['role'] as String? ?? 'user';
    } catch (_) {
      return 'user';
    }
  }

  static Future<void> signUp({required String email, required String password}) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _db.collection('users').doc(cred.user!.uid).set({
        'email': email.trim(),
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendly(e.code), e.code);
    }
  }

  static Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendly(e.code), e.code);
    }
  }

  static Future<void> signOut() => _auth.signOut();

  static String _friendly(String code) {
    switch (code) {
      case 'invalid-email':          return 'Please enter a valid email address.';
      case 'user-not-found':         return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':     return 'Incorrect email or password.';
      case 'email-already-in-use':   return 'An account already exists with this email.';
      case 'weak-password':          return 'Password must be at least 6 characters.';
      case 'network-request-failed': return 'Network error. Check your connection.';
      case 'too-many-requests':      return 'Too many attempts. Please wait and try again.';
      default:                       return 'Something went wrong. Please try again.';
    }
  }
}
