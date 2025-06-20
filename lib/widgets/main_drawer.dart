// File: lib/widgets/main_drawer.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
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
    // Mendapatkan status pengguna dari Provider
    final user = Provider.of<User?>(context);
    final bool isLoggedIn = user != null;

    return Drawer(
      backgroundColor: Colors.white,
      // Menggunakan Column sebagai widget utama untuk kontrol posisi
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Bagian Header (tidak berubah)
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
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.close, size: 28, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Gambar Museum (tidak berubah)
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
              icon: Icons.favorite, // Ikon diubah menjadi terisi
              color: Colors.red, // Warna ikon diubah (opsional)
              title: 'Koleksi Favorit',
              onTap: () {
                // # PERUBAHAN: Navigasi ke halaman favorit
                Navigator.pop(context); // Tutup drawer dulu
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FavoritesScreen()),
                );
              },
            ),
          ] else ...[
            // JIKA BELUM LOGIN
            IconWidget(
              icon: FontAwesomeIcons.google,
              title: 'Login dengan Google',
              onTap: () async {
                // # PERBAIKAN: Simpan referensi sebelum menutup drawer
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                // Tutup drawer terlebih dahulu
                navigator.pop();

                // Panggil fungsi login dan tunggu hasilnya
                final user = await AuthService().signInWithGoogle();

                // Tampilkan pesan jika login berhasil
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
