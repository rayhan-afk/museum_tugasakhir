// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:museum_tugasakhir/providers/theme_providers.dart';
import 'package:provider/provider.dart';

// Ganti 'museum_tugasakhir' dengan nama proyek Anda
import 'package:museum_tugasakhir/services/auth_service.dart';
import 'package:museum_tugasakhir/screens/tabs.dart'; // Import halaman Tabs
import 'package:museum_tugasakhir/services/firebase_options.dart';

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
        // 1. Provider untuk status otentikasi
        StreamProvider<User?>.value(
          value: AuthService().authStateChanges,
          initialData: null,
        ),
        // 2. Provider untuk tema
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
      ],
      // # PERUBAHAN UTAMA: Menggunakan Consumer untuk membangun MaterialApp
      // Ini memastikan kita menggunakan context yang benar.
      child: const MyApp(),
    ),
  );
}

//--- Widget Aplikasi Utama (MyApp) ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan Consumer untuk "mendengarkan" perubahan dari ThemeProvider
    // dan mendapatkan context yang sudah "melihat" provider tersebut.
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Museum Geologi App',
          debugShowCheckedModeBanner: false,

          // Mengatur tema aplikasi berdasarkan provider
          theme: MyThemes.lightTheme,
          darkTheme: MyThemes.darkTheme,
          themeMode: themeProvider.themeMode,

          // Mengarahkan home ke widget Tabs()
          home: const Tabs(),
        );
      },
    );
  }
}
