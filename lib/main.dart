import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:museum_tugasakhir/services/firebase_options.dart';
import 'package:provider/provider.dart';

// Ganti 'museum_tugasakhir' dengan nama folder proyek Anda
import 'package:museum_tugasakhir/services/auth_service.dart';
import 'package:museum_tugasakhir/screens/tabs.dart'; // Import halaman Tabs

void main() async {
  // Memastikan semua binding Flutter sudah siap sebelum menjalankan kode
  WidgetsFlutterBinding.ensureInitialized();
  // Menginisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // Membungkus seluruh aplikasi dengan MultiProvider.
    // Ini memungkinkan kita untuk menyediakan beberapa 'state' atau 'service'.
    MultiProvider(
      providers: [
        // Menyediakan stream status otentikasi ke seluruh aplikasi.
        // Setiap kali ada perubahan (login/logout), widget yang mendengarkan akan otomatis update.
        StreamProvider<User?>.value(
          value: AuthService().authStateChanges,
          initialData: null,
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
    return MaterialApp(
      title: 'Museum Geologi App', // Judul aplikasi Anda
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      theme: ThemeData(
        // Konfigurasi tema utama aplikasi Anda
        primarySwatch: Colors.orange, // Menggunakan tema oranye/kuning
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Mengarahkan home ke widget Tabs()
      home: const Tabs(), // Halaman utama aplikasi Anda
    );
  }
}

//rayhan abduhuda - 193040044
