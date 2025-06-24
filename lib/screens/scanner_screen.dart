import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:museum_tugasakhir/screens/camera_scanner.dart';
// Kita akan membuat file ini nanti

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ikon besar sebagai ilustrasi
              Icon(
                Icons.qr_code_scanner_rounded,
                size: 150,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 40),

              // Judul Halaman
              Text(
                'Pindai Kode QR Koleksi',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Teks Deskripsi
              Text(
                'Arahkan kamera ke kode QR yang ada di dekat setiap item koleksi untuk melihat detailnya.',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 50),

              // Tombol untuk Memulai Scan
              SizedBox(
                width: double.infinity, // Membuat tombol selebar layar
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Mulai Scan'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: const Color(0xFFFFA000), // Warna oranye
                    foregroundColor: Colors.black, // Warna teks
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    // Navigasi ke halaman kamera scanner (yang akan kita buat selanjutnya)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CameraScannerPage(),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
