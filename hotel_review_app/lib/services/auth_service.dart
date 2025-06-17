// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream untuk memantau status autentikasi
  Stream<User?> get user => _auth.authStateChanges();

  // Mendapatkan User saat ini
  User? get currentUser => _auth.currentUser;

  // Fungsi untuk Registrasi dengan Email & Password
  Future<User?> registerWithEmailAndPassword(
      String email, String password, String fullName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Simpan informasi tambahan pengguna ke Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'fullName': fullName,
          'email': email,
          'createdAt': Timestamp.now(),
        });
        // Perbarui nama tampilan di Firebase Auth
        await user.updateDisplayName(fullName);
      }
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Fungsi untuk Login dengan Email & Password
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Fungsi untuk Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}