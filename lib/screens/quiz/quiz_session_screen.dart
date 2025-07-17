// File: lib/screens/quiz_session_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:museum_tugasakhir/services/firestore_service.dart';

class QuizSessionScreen extends StatefulWidget {
  const QuizSessionScreen({Key? key}) : super(key: key);

  @override
  State<QuizSessionScreen> createState() => _QuizSessionScreenState();
}

class _QuizSessionScreenState extends State<QuizSessionScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  // State untuk menyimpan data kuis
  bool _isLoading = true;
  List<DocumentSnapshot> _quizDocuments = [];
  int _currentQuestionIndex = 0;

  // State untuk pertanyaan saat ini
  String _currentQuestion = '';
  List<String> _shuffledOptions = [];
  String? _selectedAnswer;

  // State untuk menyimpan jawaban pengguna
  final Map<int, String> _userAnswers = {};

  @override
  void initState() {
    super.initState();
    _loadAndShuffleQuizzes();
  }

  // Fungsi untuk memuat semua kuis dari Firestore dan mengacaknya
  Future<void> _loadAndShuffleQuizzes() async {
    final quizzes = await _firestoreService.getAllQuizzes();
    quizzes.shuffle(); // Acak urutan soal
    if (mounted) {
      setState(() {
        _quizDocuments = quizzes;
        _isLoading = false;
      });
      _setupCurrentQuestion(); // Siapkan soal pertama
    }
  }

  // Fungsi untuk menyiapkan data soal dan jawaban yang sudah diacak
  void _setupCurrentQuestion() {
    if (_quizDocuments.isEmpty ||
        _currentQuestionIndex >= _quizDocuments.length) return;

    final quizData =
        _quizDocuments[_currentQuestionIndex].data() as Map<String, dynamic>;
    final options = List<String>.from(quizData['options'] ?? []);

    options.shuffle(); // Acak urutan pilihan jawaban

    setState(() {
      _currentQuestion = quizData['question'] ?? 'Pertanyaan tidak ditemukan';
      _shuffledOptions = options;
      // Atur kembali jawaban yang sudah dipilih jika pengguna kembali ke soal sebelumnya
      _selectedAnswer = _userAnswers[_currentQuestionIndex];
    });
  }

  // Fungsi yang dipanggil saat tombol Lanjut atau Selesai ditekan
  void _nextQuestion() {
    // Simpan jawaban pengguna untuk pertanyaan saat ini
    if (_selectedAnswer != null) {
      _userAnswers[_currentQuestionIndex] = _selectedAnswer!;
    } else {
      // Tampilkan pesan jika pengguna belum memilih jawaban
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus memilih satu jawaban!')),
      );
      return; // Hentikan fungsi jika belum ada jawaban
    }

    // Cek apakah ini soal terakhir
    if (_currentQuestionIndex < _quizDocuments.length - 1) {
      // Jika bukan soal terakhir, lanjut ke soal berikutnya
      setState(() {
        _currentQuestionIndex++;
      });
      _setupCurrentQuestion();
    } else {
      // Jika ini soal terakhir, hitung skor dan tampilkan hasil
      _calculateAndShowResults();
    }
  }

  // Fungsi untuk menghitung skor dan menampilkan dialog hasil
  void _calculateAndShowResults() async {
    int correctCount = 0;
    for (int i = 0; i < _quizDocuments.length; i++) {
      final quizData = _quizDocuments[i].data() as Map<String, dynamic>;
      final correctAnswerIndex = quizData['correctAnswerIndex'] as int;
      final correctAnswerText =
          quizData['options'][correctAnswerIndex] as String;

      if (_userAnswers[i] == correctAnswerText) {
        correctCount++;
      }
    }

    int finalScore = ((correctCount / _quizDocuments.length) * 100).round();
    DocumentSnapshot? awardedBadge;

    final user = Provider.of<User?>(context, listen: false);
    if (user != null) {
      await _firestoreService.updateUserScore(user, finalScore);
      // Cek apakah pengguna mendapatkan lencana "Ahli Sejarah"
      awardedBadge =
          await _firestoreService.trackQuizScore(user.uid, finalScore);
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Kuis Selesai!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tampilkan info lencana jika didapatkan
              if (awardedBadge != null) ...[
                Text('Selamat!',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Icon(FontAwesomeIcons.award,
                    color: Colors.orange[700], size: 40),
                const SizedBox(height: 8),
                Text(
                  'Anda mendapatkan lencana "${awardedBadge.get('name')}"!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                const Divider(height: 30),
              ],
              Text('Skor Akhir Anda:',
                  style: GoogleFonts.montserrat(fontSize: 18)),
              const SizedBox(height: 10),
              Text('$finalScore',
                  style: GoogleFonts.montserrat(
                      fontSize: 48, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('($correctCount dari ${_quizDocuments.length} soal benar)',
                  style: GoogleFonts.montserrat(fontSize: 16)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Selesai'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLastQuestion = _currentQuestionIndex == _quizDocuments.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading
            ? 'Memuat Kuis...'
            : 'Kuis: Soal ${_currentQuestionIndex + 1}/${_quizDocuments.length}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(_currentQuestion,
                      style: GoogleFonts.montserrat(
                          fontSize: 22, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 40),
                  ..._shuffledOptions.map((option) {
                    bool isSelected = _selectedAnswer == option;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: ElevatedButton(
                        onPressed: () => setState(() {
                          _selectedAnswer = option;
                        }),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: isSelected
                              ? Colors.orange[700]
                              : Colors.grey[200],
                          foregroundColor:
                              isSelected ? Colors.white : Colors.black,
                        ),
                        child: Text(option),
                      ),
                    );
                  }).toList(),
                  const Spacer(),
                  // Navigasi Bawah
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        backgroundColor: isLastQuestion
                            ? Colors.green
                            : Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      icon: Text(isLastQuestion ? 'Selesai' : 'Next'),
                      label:
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
