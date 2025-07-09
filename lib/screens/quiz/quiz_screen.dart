// File: lib/screens/quiz_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:museum_tugasakhir/screens/quiz/quiz_session_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:museum_tugasakhir/services/firestore_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _isLoading =
      false; // State untuk menandai proses loading saat tombol ditekan

  // # PERUBAHAN: State untuk menyimpan dan menampilkan jumlah percobaan
  int? _attempts;
  bool _isFetchingAttempts = true;

  @override
  void initState() {
    super.initState();
    _fetchAttempts(); // Ambil data percobaan saat halaman pertama kali dibuka
  }

  // Fungsi untuk mengambil jumlah percobaan dari Firestore
  Future<void> _fetchAttempts() async {
    final user = Provider.of<User?>(context, listen: false);
    if (user != null) {
      final attemptsCount = await FirestoreService().getQuizAttempts(user.uid);
      if (mounted) {
        setState(() {
          _attempts = attemptsCount;
          _isFetchingAttempts = false;
        });
      }
    } else {
      // Jika pengguna belum login, anggap percobaan 0
      setState(() {
        _attempts = 0;
        _isFetchingAttempts = false;
      });
    }
  }

  // Fungsi yang akan dipanggil saat tombol "Mulai" ditekan
  Future<void> _startQuiz() async {
    final user = Provider.of<User?>(context, listen: false);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login untuk memulai kuis.')),
      );
      return;
    }

    // # PERUBAHAN: Pengecekan sekarang menggunakan state _attempts
    if (_attempts != null && _attempts! < 3) {
      // Jika masih bisa bermain, navigasi ke halaman sesi kuis
      // Kita tunggu hasilnya, lalu refresh data percobaan
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const QuizSessionScreen()),
      );
      // Setelah kembali dari kuis, refresh jumlah percobaan
      _fetchAttempts();
    } else {
      // Jika sudah mencapai batas, tampilkan pesan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Anda sudah mencapai batas maksimal bermain kuis (3 kali).'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kuis Penjelajah',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard_outlined),
            tooltip: 'Papan Peringkat',
            onPressed: () {
              // TODO: Navigasi ke halaman leaderboard
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: _isFetchingAttempts
              ? const CircularProgressIndicator() // Tampilkan loading saat pertama kali memuat
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.school_outlined,
                        size: 150, color: Colors.orange.withOpacity(0.5)),
                    const SizedBox(height: 40),
                    Text(
                      'Selamat Datang di Kuis Penjelajah Museum!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Uji pengetahuanmu tentang koleksi museum. Jawab pertanyaan untuk mendapatkan skor dan naik ke papan peringkat!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                          fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 30),

                    // # PERUBAHAN: Menampilkan informasi batas kuis
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Kesempatan Bermain: ${_attempts ?? 0}/3',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tombol untuk Memulai
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              textStyle: GoogleFonts.montserrat(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: _startQuiz,
                            child: const Text('Mulai'),
                          )
                  ],
                ),
        ),
      ),
    );
  }
}
