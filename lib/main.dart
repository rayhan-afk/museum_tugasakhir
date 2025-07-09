import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:museum_tugasakhir/providers/theme_providers.dart';
import 'package:provider/provider.dart';

// Ganti 'museum_tugasakhir' dengan nama proyek Anda
import 'package:museum_tugasakhir/services/auth_service.dart';
import 'package:museum_tugasakhir/screens/splash_screen.dart'; // <-- IMPORT HALAMAN BARU
import 'services/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        StreamProvider<User?>.value(
          value: AuthService().authStateChanges,
          initialData: null,
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Museum Geologi App',
      debugShowCheckedModeBanner: false,
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      themeMode: themeProvider.themeMode,

      // # PERUBAHAN UTAMA: Halaman pertama sekarang adalah SplashScreen
      home: const SplashScreen(),
    );
  }
}
