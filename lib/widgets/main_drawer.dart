// File: lib/widgets/main_drawer.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:museum_tugasakhir/providers/theme_providers.dart';
import 'package:museum_tugasakhir/screens/comments_screen.dart';
import 'package:museum_tugasakhir/screens/favorite_screen.dart';
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
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, // Menggunakan warna tema
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
                  // # PERUBAHAN: Tombol diubah dan dibungkus CircleAvatar
                  CircleAvatar(
                    backgroundColor: Colors.black
                        .withOpacity(0.1), // Latar belakang lingkaran
                    child: IconButton(
                      icon: Icon(
                        isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                        // Matahari warna putih, bulan warna hitam
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      onPressed: () {
                        // Memanggil fungsi toggleTheme dengan nilai kebalikannya
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

          // Tombol Setting yang selalu ada di grup atas
          IconWidget(
            icon: Icons.settings,
            title: 'Setting',
            onTap: () {
              // TODO: Navigasi ke halaman setting
            },
          ),

          // Spacer untuk mendorong sisa item ke bawah
          const Spacer(),

          // --- BAGIAN BAWAH YANG SELALU MENEMPEL ---

          // Tombol Logout hanya muncul jika sudah login
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

          // --- Ikon Sosial Media ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SocialIcon(icon: Icons.facebook, onTap: () {}),
                SocialIcon(icon: FontAwesomeIcons.instagram, onTap: () {}),
                SocialIcon(icon: FontAwesomeIcons.twitter, onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
