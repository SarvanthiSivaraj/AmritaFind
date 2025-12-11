import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // Singleton instance
  static final AuthService instance = AuthService._();
  AuthService._();

  /// CHECK IF USER LOGGED IN
  static bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  /// CURRENT USER
  static User? get currentUser => FirebaseAuth.instance.currentUser;

  /// LOGIN WITH EMAIL & PASSWORD + AUTO USER CREATION IN FIRESTORE
  Future<String?> login(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // After login, ensure that Firestore has a user profile document
      await _createUserDocIfMissing(credential.user);

      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Login error";
    } catch (e) {
      return "Something went wrong";
    }
  }

  /// SIGNUP (IN CASE YOU ADD THIS LATER)
  Future<String?> signup(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create Firestore profile after signup
      await _createUserDocIfMissing(credential.user);

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Signup error";
    } catch (e) {
      return "Something went wrong";
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  /// CREATE USER PROFILE DOCUMENT IF IT DOES NOT EXIST
  Future<void> _createUserDocIfMissing(User? user) async {
    if (user == null) return;

    final docRef =
        FirebaseFirestore.instance.collection("users").doc(user.uid);

    final docSnapshot = await docRef.get();

    // Only create default profile if missing
    if (!docSnapshot.exists) {
      await docRef.set({
        "email": user.email,
        "name": "",
        "phone": "",
        "photoUrl": "",
        "createdAt": DateTime.now(),
      });
    }
  }

  /// UPDATE USER PROFILE IN FIRESTORE
  Future<void> updateProfile({
    required String name,
    required String phone,
    required String photoUrl,
  }) async {
    final user = currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
      "name": name,
      "phone": phone,
      "photoUrl": photoUrl,
    });
  }
}
