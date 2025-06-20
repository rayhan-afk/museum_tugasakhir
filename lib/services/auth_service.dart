import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Membuat instance dari Firebase Auth dan Google Sign-In
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream untuk mendengarkan perubahan status login (login, logout, dll.)
  // Ini akan kita gunakan nanti dengan Provider untuk memberitahu seluruh aplikasi.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Getter untuk mendapatkan pengguna yang sedang login saat ini
  User? get currentUser => _firebaseAuth.currentUser;

  // --- FUNGSI UTAMA UNTUK OTENTIKASI ---

  // 1. Fungsi untuk memulai proses Login dengan Google
  Future<User?> signInWithGoogle() async {
    try {
      // Memunculkan dialog pop-up untuk memilih akun Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Jika pengguna membatalkan atau menutup dialog
      if (googleUser == null) {
        return null;
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

      // Mengembalikan data pengguna dari Firebase
      return userCredential.user;
    } catch (e) {
      // Menangani jika terjadi error
      print('Error saat login dengan Google: $e');
      return null;
    }
  }

  // 2. Fungsi untuk Logout
  Future<void> signOut() async {
    try {
      // Logout dari Google dan Firebase
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Error saat logout: $e');
    }
  }
}
