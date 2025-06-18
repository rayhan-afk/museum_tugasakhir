// File: lib/screens/collections_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Ganti 'museum_tugasakhir' dengan nama proyek Anda
import 'package:museum_tugasakhir/screens/categories/category_items_screen.dart'; // # PERUBAHAN: Import halaman baru
import 'package:museum_tugasakhir/screens/details/search.dart';
import 'package:museum_tugasakhir/widgets/categories_tile.dart';
import 'package:museum_tugasakhir/data/data.dart'; // Untuk model data
import 'package:museum_tugasakhir/screens/details/details.dart'; // Untuk halaman detail

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Kolom Pencarian (Tetap Sama) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 20.0),
              child: Container(
                // ... kode search bar Anda ...
                child: TextField(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SearchScreen()));
                  },
                  readOnly: true,
                  style: GoogleFonts.montserrat(),
                  decoration: InputDecoration(
                    hintText: 'Search for items...',
                    hintStyle: GoogleFonts.montserrat(color: Colors.grey[600]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),

                    filled: true,
                    fillColor: Colors.grey[200],

                    // Mengatur border saat tidak aktif
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(
                        color: Colors.transparent, // Border transparan
                      ),
                    ),

                    // # PERUBAHAN: Mengatur border saat di-tap (fokus)
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(
                        color:
                            Colors.transparent, // Border juga dibuat transparan
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // --- Judul Kategori (Tetap Sama) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Text('Categories',
                      style: GoogleFonts.montserrat(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // --- # PERUBAHAN: NAVIGASI KATEGORI ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CategoryItemsScreen(
                                  categoryName: 'Artefak')));
                    },
                    child: CategoriesTile(
                        imageUrl: 'assets/image/artefak.png', text: 'Artefak'),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CategoryItemsScreen(
                                  categoryName: 'Batuan')));
                    },
                    child: CategoriesTile(
                        imageUrl: 'assets/image/batuan.png', text: 'Batuan'),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CategoryItemsScreen(
                                  categoryName: 'Fosil')));
                    },
                    child: CategoriesTile(
                        imageUrl: 'assets/image/fosil.png', text: 'Fosil'),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CategoryItemsScreen(
                                  categoryName: 'Mineral')));
                    },
                    child: CategoriesTile(
                        imageUrl: 'assets/image/mineral.png', text: 'Mineral'),
                  ),
                ],
              ),
            ),

            // --- Judul Most Popular (Tetap Sama) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Text('Most Popular',
                      style: GoogleFonts.montserrat(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // --- # PERUBAHAN: BAGIAN MOST POPULAR DINAMIS ---
            const Padding(
              padding: EdgeInsets.all(20),
              child:
                  MostPopularWidget(), // Menggunakan widget baru yang dinamis
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET BARU UNTUK MENAMPILKAN ITEM PALING POPULER ---
// Anda bisa letakkan ini di file terpisah (misal: lib/widgets/most_popular_widget.dart)
// atau biarkan di sini jika sederhana.

class MostPopularWidget extends StatelessWidget {
  const MostPopularWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Query untuk mengambil 1 item secara acak/teratas dari koleksi
    // Untuk "paling populer" sebenarnya, Anda butuh field seperti 'viewCount' dan diurutkan.
    // Untuk sekarang, kita ambil 1 saja sebagai contoh.
    final Query query =
        FirebaseFirestore.instance.collection('koleksi').limit(1);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
              height: 300, child: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox(
              height: 300,
              child: Center(child: Text('Tidak ada item populer.')));
        }

        // Ambil data dari dokumen pertama
        final doc = snapshot.data!.docs.first;
        final data = doc.data()! as Map<String, dynamic>;

        // Tampilan yang sama seperti sebelumnya, tapi dengan data dinamis
        return GestureDetector(
          onTap: () {
            // Navigasi ke halaman detail saat gambar di-tap
            final category = data['category'] ?? '';
            Object? itemData;
            // Buat model data yang benar berdasarkan kategori
            switch (category) {
              case 'Artefak':
                itemData = ArtefakData.fromFirestore(data);
                break;
              case 'Batuan':
                itemData = BatuanData.fromFirestore(data);
                break;
              case 'Fosil':
                itemData = FosilData.fromFirestore(data);
                break;
              case 'Mineral':
                itemData = MineralData.fromFirestore(data);
                break;
            }

            if (itemData != null) {
              Widget detailScreen;
              if (itemData is ArtefakData)
                detailScreen = ArtefakDetailScreen(artefakData: itemData);
              else if (itemData is BatuanData)
                detailScreen = BatuanDetailScreen(batuanData: itemData);
              else if (itemData is FosilData)
                detailScreen = FosilDetailScreen(fosilData: itemData);
              else if (itemData is MineralData)
                detailScreen = MineralDetailScreen(mineralData: itemData);
              else
                detailScreen = const Scaffold(
                    body: Center(child: Text('Tipe data tidak valid')));

              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => detailScreen));
            }
          },
          child: Container(
            clipBehavior: Clip.antiAlias,
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(23),
            ),
            child: Stack(
              children: [
                Image.network(
                  data['imageUrl'] ?? 'https://placehold.co/600x400/EEE/31343C',
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration:
                        BoxDecoration(color: Colors.black.withOpacity(0.5)),
                    child: Text(
                      data['title'] ?? 'Tanpa Judul',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
