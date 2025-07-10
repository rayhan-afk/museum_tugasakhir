// File: lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:museum_tugasakhir/services/firestore_service.dart'; // <-- IMPORT BARU

class AuthService {
  // Membuat instance dari Firebase Auth, Google Sign-In, dan Firestore Service
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService =
      FirestoreService(); // <-- TAMBAHKAN INI

  // Stream untuk mendengarkan perubahan status login
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Getter untuk mendapatkan pengguna yang sedang login saat ini
  User? get currentUser => _firebaseAuth.currentUser;

  // --- FUNGSI UTAMA UNTUK OTENTIKASI ---

  // 1. Fungsi untuk memulai proses Login dengan Google
  Future<User?> signInWithGoogle() async {
    try {
      // Memunculkan dialog pop-up untuk memilih akun Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // Pengguna membatalkan login
      }

      // Mendapatkan detail otentikasi dari akun Google yang dipilih
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Membuat kredensial untuk Firebase dari token Google
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Menggunakan kredensial untuk login ke Firebase
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      // # PERUBAHAN UTAMA: Setelah login berhasil, simpan/update data pengguna
      if (user != null) {
        await _firestoreService.updateUserData(user);
      }

      // Mengembalikan data pengguna dari Firebase
      return user;
    } catch (e) {
      // Menangani jika terjadi error
      print('Error saat login dengan Google: $e');
      return null;
    }
  }

  // 2. Fungsi untuk Logout
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Error saat logout: $e');
    }
  }
}
