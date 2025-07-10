import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:museum_tugasakhir/screens/tabs.dart'; // Import halaman utama Anda

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // State untuk mengontrol animasi
  bool _logoVisible = false;
  bool _titleVisible = false;
  bool _subtitleVisible = false;

  @override
  void initState() {
    super.initState();
    // Memulai urutan animasi
    _startAnimation();
  }

  void _startAnimation() {
    // Timer untuk navigasi ke halaman utama
    Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const Tabs(),
          ),
        );
      }
    });

    // Urutan animasi muncul
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _logoVisible = true);
    });
    Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _titleVisible = true);
    });
    Timer(const Duration(milliseconds: 1700), () {
      if (mounted) setState(() => _subtitleVisible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Menggunakan gradient yang sama dengan tema
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo dengan animasi scale dan fade
              AnimatedOpacity(
                opacity: _logoVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                child: AnimatedScale(
                  scale: _logoVisible ? 1.0 : 0.5,
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutBack,
                  child: const Icon(
                    Icons.museum_outlined,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Judul Utama dengan animasi fade
              AnimatedOpacity(
                opacity: _titleVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Text(
                  'Museum Geologi',
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ),

              // Sub-judul dengan animasi fade
              AnimatedOpacity(
                opacity: _subtitleVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Text(
                  'Bandung',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),

              // Loading indicator yang muncul di akhir
              const SizedBox(height: 80),
              AnimatedOpacity(
                opacity: _subtitleVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
