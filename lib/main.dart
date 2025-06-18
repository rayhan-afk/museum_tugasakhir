import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:museum_tugasakhir/screens/tabs.dart';
import 'package:museum_tugasakhir/services/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Museum App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Untuk sementara, kita bisa langsung arahkan ke MuseumInfoPage
      // atau buat tombol di HomePage untuk ke sana
      home: const Tabs(), // Langsung ke halaman info museum
    );
  }
}
