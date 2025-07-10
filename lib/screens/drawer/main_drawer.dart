// File: lib/widgets/main_drawer.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:museum_tugasakhir/providers/theme_providers.dart';
import 'package:museum_tugasakhir/screens/drawer/comments_screen.dart';
import 'package:museum_tugasakhir/screens/drawer/favorite_screen.dart';
import 'package:museum_tugasakhir/screens/quiz/quiz_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Ganti 'museum_tugasakhir' dengan nama proyek Anda
import 'package:museum_tugasakhir/widgets/icon_widget.dart';
import 'package:museum_tugasakhir/widgets/social_icon.dart';
import 'package:museum_tugasakhir/services/auth_service.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mendapatkan status pengguna dan tema dari Provider
    final user = Provider.of<User?>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isLoggedIn = user != null;
    final bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Bagian Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Museum Geologi',
                          style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      Text('Bandung',
                          style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.1),
                    child: IconButton(
                      icon: Icon(
                        isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      onPressed: () {
                        themeProvider.toggleTheme(!isDarkMode);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Gambar Museum
          Center(
            child: Container(
              width: 260,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                image: const DecorationImage(
                  image: AssetImage('assets/image/museumgambar.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // --- BAGIAN MENU UTAMA ---
          if (isLoggedIn) ...[
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.photoURL ?? ''),
                radius: 20,
              ),
              title: Text(
                'Welcome, ${user.displayName ?? 'Pengguna'}',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              ),
            ),
            IconWidget(
              icon: Icons.favorite,
              color: Colors.red,
              title: 'Koleksi Favorit',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FavoritesScreen()),
                );
              },
            ),
            IconWidget(
              icon: Icons.comment_outlined,
              title: 'Komentar Saya',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MyCommentsScreen()),
                );
              },
            ),
          ] else ...[
            // JIKA BELUM LOGIN
            IconWidget(
              icon: FontAwesomeIcons.google,
              title: 'Login dengan Google',
              onTap: () async {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                navigator.pop();
                final user = await AuthService().signInWithGoogle();
                if (user != null) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Selamat datang, ${user.displayName}!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
          ],

          // Tombol Quiz
          IconWidget(
            icon: Icons.quiz_sharp,
            title: 'Kuis',
            onTap: () async {
              // <-- Dibuat async
              final user = Provider.of<User?>(context, listen: false);

              // # PERBAIKAN: Simpan referensi ke ScaffoldMessenger SEBELUM pop
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              // Tutup drawer
              Navigator.pop(context);

              if (user != null) {
                // Jika sudah login, langsung navigasi
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuizScreen()),
                );
              } else {
                // Jika belum login, tunggu sebentar lalu tampilkan SnackBar
                await Future.delayed(const Duration(milliseconds: 300));
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Anda harus login terlebih dahulu untuk memulai quiz.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),

          // Tombol Setting
          // IconWidget(
          //   icon: Icons.settings,
          //   title: 'Setting',
          //   onTap: () {
          //     // TODO: Navigasi ke halaman setting
          //   },
          // ),

          const Spacer(),

          // Tombol Logout
          if (isLoggedIn) ...[
            const Divider(height: 1, thickness: 1),
            IconWidget(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () async {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                navigator.pop();
                await AuthService().signOut();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Anda telah berhasil logout.'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ],

          // Ikon Sosial Media
          // Padding(
          //   padding: const EdgeInsets.symmetric(vertical: 10.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     children: [
          //       SocialIcon(icon: Icons.facebook, onTap: () {}),
          //       SocialIcon(icon: FontAwesomeIcons.instagram, onTap: () {}),
          //       SocialIcon(icon: FontAwesomeIcons.twitter, onTap: () {}),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
