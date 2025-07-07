import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:museum_tugasakhir/providers/theme_providers.dart';
import 'package:provider/provider.dart';

// Ganti 'museum_tugasakhir' dengan nama proyek Anda
import 'package:museum_tugasakhir/services/auth_service.dart';
import 'package:museum_tugasakhir/screens/tabs.dart'; // Import halaman Tabs
import 'services/firebase_options.dart';

void main() async {
  // Memastikan semua binding Flutter sudah siap sebelum menjalankan kode
  WidgetsFlutterBinding.ensureInitialized();
  // Menginisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // Membungkus seluruh aplikasi dengan MultiProvider.
    MultiProvider(
      providers: [
        // 1. Provider untuk status otentikasi (tetap ada)
        StreamProvider<User?>.value(
          value: AuthService().authStateChanges,
          initialData: null,
        ),
        // 2. Provider untuk tema (BARU)
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
      ],
      child: const MyApp(), // Aplikasi utama Anda
    ),
  );
}

//--- Widget Aplikasi Utama (MyApp) digabungkan di sini ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // "Mendengarkan" perubahan dari ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Museum Geologi App',
      debugShowCheckedModeBanner: false,

      // # PERUBAHAN UTAMA: Mengatur tema aplikasi
      theme: MyThemes.lightTheme, // Tema saat mode terang
      darkTheme: MyThemes.darkTheme, // Tema saat mode gelap
      themeMode: themeProvider.themeMode, // Menggunakan mode yang sedang aktif

      // Mengarahkan home ke widget Tabs()
      home: const Tabs(), // Halaman utama aplikasi Anda
    );
  }
}
