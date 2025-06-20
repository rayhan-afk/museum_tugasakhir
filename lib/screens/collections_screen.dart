// File: lib/screens/collections_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Ganti 'museum_tugasakhir' dengan nama proyek Anda
import 'package:museum_tugasakhir/screens/categories/category_items_screen.dart';
import 'package:museum_tugasakhir/screens/details/search.dart';
import 'package:museum_tugasakhir/widgets/categories_tile.dart';
import 'package:museum_tugasakhir/data/data.dart';
import 'package:museum_tugasakhir/screens/details/details.dart';

// --- FUNGSI PEMBANTU (HELPER FUNCTIONS) DITARUH DI LUAR KELAS ---
// Ini membuat fungsi bisa diakses dengan lebih mudah dan konsisten.

// Tugas: Memilih halaman detail yang benar untuk dibuka.
Widget createDetailScreen(Object data) {
  if (data is ArtefakData) return ArtefakDetailScreen(artefakData: data);
  if (data is BatuanData) return BatuanDetailScreen(batuanData: data);
  if (data is FosilData) return FosilDetailScreen(fosilData: data);
  if (data is MineralData) return MineralDetailScreen(mineralData: data);
  return const Scaffold(body: Center(child: Text('Tipe data tidak valid')));
}

// Tugas: Mengubah data mentah (Map) dari Firestore menjadi objek data.
Object? createDataModel(Map<String, dynamic> firestoreData, String docId) {
  final category = firestoreData['category'] as String?;
  if (category == null) return null;

  switch (category) {
    case 'Artefak':
      return ArtefakData.fromFirestore(firestoreData, docId);
    case 'Batuan':
      return BatuanData.fromFirestore(firestoreData, docId);
    case 'Fosil':
      return FosilData.fromFirestore(firestoreData, docId);
    case 'Mineral':
      return MineralData.fromFirestore(firestoreData, docId);
    default:
      return null;
  }
}
// --- AKHIR DARI FUNGSI PEMBANTU ---

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Kolom Pencarian ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 20.0),
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
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                ),
              ),
            ),

            // --- Judul Kategori ---
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

            // --- Navigasi Kategori ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CategoryItemsScreen(
                                categoryName: 'Artefak'))),
                    child: CategoriesTile(
                        imageUrl: 'assets/image/artefak.png', text: 'Artefak'),
                  ),
                  InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CategoryItemsScreen(
                                categoryName: 'Batuan'))),
                    child: CategoriesTile(
                        imageUrl: 'assets/image/batuan.png', text: 'Batuan'),
                  ),
                  InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CategoryItemsScreen(
                                categoryName: 'Fosil'))),
                    child: CategoriesTile(
                        imageUrl: 'assets/image/fosil.png', text: 'Fosil'),
                  ),
                  InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CategoryItemsScreen(
                                categoryName: 'Mineral'))),
                    child: CategoriesTile(
                        imageUrl: 'assets/image/mineral.png', text: 'Mineral'),
                  ),
                ],
              ),
            ),

            // --- Judul Most Popular ---
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

            // --- Bagian Most Popular Dinamis ---
            const Padding(
              padding: EdgeInsets.all(20),
              child: MostPopularWidget(),
            ),
          ],
        ),
      ),
    );
  }
}

// WIDGET BARU UNTUK MENAMPILKAN ITEM PALING POPULER
class MostPopularWidget extends StatelessWidget {
  const MostPopularWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // # PERUBAHAN UTAMA: Query sekarang mengurutkan berdasarkan favoriteCount
    final Query query = FirebaseFirestore.instance
        .collection('koleksi')
        .orderBy('favoriteCount',
            descending: true) // Urutkan dari yang paling banyak difavoritkan
        .limit(1); // Ambil 1 item teratas

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

        final doc = snapshot.data!.docs.first;
        final data = doc.data()! as Map<String, dynamic>;

        return GestureDetector(
          onTap: () {
            final itemData = createDataModel(data, doc.id);
            if (itemData != null) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => createDetailScreen(itemData)));
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
