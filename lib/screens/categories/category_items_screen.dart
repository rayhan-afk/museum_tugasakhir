// File: lib/screens/categories/category_items_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Ganti 'museum_tugasakhir' dengan nama proyek Anda
import 'package:museum_tugasakhir/services/firestore_service.dart';
import 'package:museum_tugasakhir/helpers/navigation_helper.dart'; // <-- IMPORT FILE HELPER BARU

class CategoryItemsScreen extends StatefulWidget {
  final String categoryName;

  const CategoryItemsScreen({Key? key, required this.categoryName})
      : super(key: key);

  @override
  State<CategoryItemsScreen> createState() => _CategoryItemsScreenState();
}

class _CategoryItemsScreenState extends State<CategoryItemsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    // Panggil fungsi pelacakan saat halaman pertama kali dibuka
    _trackCategoryView();
  }

  // --- FUNGSI UNTUK LENCANA ---

  /// Fungsi untuk menampilkan dialog saat lencana baru didapatkan.
  void _showBadgeAwardedDialog(DocumentSnapshot badgeDoc) {
    final badgeData = badgeDoc.data() as Map<String, dynamic>;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(FontAwesomeIcons.award, color: Colors.orange[700]),
            const SizedBox(width: 10),
            const Text('Pencapaian Baru!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Selamat, Anda mendapatkan lencana:',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(
              badgeData['name'] ?? 'Lencana Baru',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              badgeData['description'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keren!'),
          ),
        ],
      ),
    );
  }

  /// Fungsi untuk memeriksa apakah ada lencana baru yang didapat.
  void _checkAndShowBadge(Future<DocumentSnapshot?> badgeFuture) async {
    final badgeDoc = await badgeFuture;
    if (badgeDoc != null && mounted) {
      _showBadgeAwardedDialog(badgeDoc);
    }
  }

  /// Melacak bahwa pengguna telah membuka halaman kategori ini.
  void _trackCategoryView() {
    // Menunggu sebentar agar Provider siap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<User?>(context, listen: false);
      if (user != null) {
        final future =
            _firestoreService.trackCategoryView(user.uid, widget.categoryName);
        _checkAndShowBadge(future);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Query query = FirebaseFirestore.instance
        .collection('koleksi')
        .where('category', isEqualTo: widget.categoryName);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName,
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Gagal memuat data.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text('Belum ada koleksi di kategori ini.',
                    style: GoogleFonts.montserrat(fontSize: 18)));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data()! as Map<String, dynamic>;
              // Memanggil fungsi helper dari file yang diimpor
              final itemData =
                  createDataModel(widget.categoryName, data, doc.id);

              return GestureDetector(
                onTap: () {
                  if (itemData != null) {
                    // Memanggil fungsi helper dari file yang diimpor
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                createDetailScreen(itemData)));
                  }
                },
                child: Container(
                  height: 250, // Tinggi kartu bisa disesuaikan
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        data['imageUrl'] ??
                            'https://placehold.co/600x400/EEE/31343C',
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) =>
                            progress == null
                                ? child
                                : const Center(
                                    child: CircularProgressIndicator()),
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                                child: Icon(Icons.broken_image, size: 40)),
                      ),
                      // Lapisan gradasi gelap di bawah agar teks lebih terbaca
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.center,
                            colors: <Color>[Colors.black87, Colors.transparent],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Text(
                          data['title'] ?? 'Tanpa Judul',
                          style: GoogleFonts.montserrat(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              const Shadow(blurRadius: 4, color: Colors.black54)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
