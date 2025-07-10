// File: lib/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Kelas ini akan menjadi "Pengontrol Tema" untuk seluruh aplikasi.
// Ia menggunakan ChangeNotifier untuk memberitahu widget lain saat ada perubahan.
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Defaultnya adalah mode terang

  // Ini adalah 'getter' agar widget lain bisa mengetahui tema apa yang sedang aktif.
  ThemeMode get themeMode => _themeMode;

  // Key untuk menyimpan data di memori HP
  static const String _themePreferenceKey = 'theme_preference';

  ThemeProvider() {
    // Saat ThemeProvider pertama kali dibuat, langsung coba muat tema yang tersimpan.
    _loadThemeFromPrefs();
  }

  // Fungsi untuk memuat preferensi tema dari memori HP
  _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    // Baca data boolean 'isDarkMode'. Jika tidak ada, defaultnya adalah false.
    final bool isDarkMode = prefs.getBool(_themePreferenceKey) ?? false;
    // Atur tema berdasarkan data yang tersimpan
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    // Beri tahu semua widget yang mendengarkan bahwa tema sudah dimuat.
    notifyListeners();
  }

  // Fungsi untuk menyimpan preferensi tema ke memori HP
  _saveThemeToPrefs(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_themePreferenceKey, isDarkMode);
  }

  // Fungsi utama yang akan dipanggil oleh tombol switch
  void toggleTheme(bool isDarkMode) {
    // Ubah tema berdasarkan nilai dari tombol switch
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    // Simpan pilihan baru ini ke memori HP
    _saveThemeToPrefs(isDarkMode);
    // Beri tahu seluruh aplikasi bahwa tema telah berubah!
    notifyListeners();
  }
}

// Kelas ini mendefinisikan seperti apa tampilan tema terang dan gelap aplikasi.
class MyThemes {
  // Tema untuk Mode Terang (Light Mode)
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.orange,
    scaffoldBackgroundColor: Colors.white,
    brightness: Brightness.light,
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFFFA000),
      foregroundColor: Colors.black, // Warna teks dan ikon di AppBar
      elevation: 1,
      titleTextStyle: GoogleFonts.montserrat(
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontSize: 22,
      ),
    ),
    // Anda bisa menambahkan kustomisasi lain di sini
  );

  // Tema untuk Mode Gelap (Dark Mode)
  static final ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.orange,
    scaffoldBackgroundColor:
        const Color(0xFF121212), // Warna latar belakang gelap
    brightness: Brightness.dark, // Memberitahu Flutter ini adalah tema gelap
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      foregroundColor: Colors.white, // Warna teks dan ikon di AppBar
      elevation: 1,
      titleTextStyle: GoogleFonts.montserrat(
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontSize: 22,
      ),
    ),
  );
}
