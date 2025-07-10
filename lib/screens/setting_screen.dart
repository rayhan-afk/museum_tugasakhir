import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = 'Memuat...';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  // Fungsi untuk mengambil versi aplikasi secara dinamis
  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion =
            'Versi ${packageInfo.version} (${packageInfo.buildNumber})';
      });
    }
  }

  // Fungsi untuk menampilkan dialog "Tentang Aplikasi"
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tentang Aplikasi'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Museum App ini dirancang untuk meningkatkan pengalaman pengunjung di Museum Geologi Bandung dengan menyediakan informasi detail, fitur interaktif, dan kuis yang menarik.',
                ),
                const SizedBox(height: 10),
                Text(
                    'Dikembangkan oleh Rayhan Abduhuda ( 193040044 ) sebagai penelitian tugas akhir.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pengaturan',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Tentang Aplikasi'),
            subtitle: const Text('Lihat informasi mengenai aplikasi ini'),
            onTap: () => _showAboutDialog(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.verified_outlined),
            title: const Text('Versi Aplikasi'),
            subtitle: Text(_appVersion),
          ),
          const Divider(),
          // Anda bisa menambahkan item pengaturan lain di sini
        ],
      ),
    );
  }
}
