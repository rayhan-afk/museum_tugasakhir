import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

// Import halaman detail dan model data Anda
// Ganti 'museum_tugasakhir' dengan nama proyek Anda
import 'package:museum_tugasakhir/data/data.dart';
import 'package:museum_tugasakhir/screens/details/details.dart';

// Ganti nama kelas di file ini menjadi CategoryItemsScreen untuk konsistensi
class CategoryItemsScreen extends StatelessWidget {
  // Properti untuk menerima nama kategori dari halaman sebelumnya (misal: "Fosil")
  final String categoryName;

  const CategoryItemsScreen({Key? key, required this.categoryName})
      : super(key: key);

  //--- FUNGSI PEMBANTU (HELPER FUNCTIONS) ---

  // Tugas: Memilih halaman detail yang benar untuk dibuka berdasarkan tipe data.
  Widget _createDetailScreen(Object data) {
    if (data is ArtefakData) {
      return ArtefakDetailScreen(artefakData: data);
    } else if (data is BatuanData) {
      return BatuanDetailScreen(batuanData: data);
    } else if (data is FosilData) {
      return FosilDetailScreen(fosilData: data);
    } else if (data is MineralData) {
      return MineralDetailScreen(mineralData: data);
    }
    // Jika tipe datanya tidak cocok, tampilkan halaman error sederhana.
    return const Scaffold(body: Center(child: Text('Tipe data tidak valid')));
  }

  // Tugas: Mengubah data mentah (Map) dari Firestore menjadi objek data yang benar
  Object? _createDataModel(
      String category, Map<String, dynamic> firestoreData) {
    switch (category) {
      case 'Artefak':
        return ArtefakData.fromFirestore(firestoreData);
      case 'Batuan':
        return BatuanData.fromFirestore(firestoreData);
      case 'Fosil':
        return FosilData.fromFirestore(firestoreData);
      case 'Mineral':
        return MineralData.fromFirestore(firestoreData);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. MEMBUAT QUERY KE FIRESTORE
    // Query ini akan mencari semua dokumen di collection 'koleksi'
    // yang field 'category'-nya sama dengan 'categoryName' yang kita terima.
    final Query query = FirebaseFirestore.instance
        .collection('koleksi') // PASTIKAN nama collection ini benar.
        .where('category',
            isEqualTo:
                categoryName); // <-- DIUBAH DARI 'kategori' MENJADI 'category'

    return Scaffold(
      // AppBar yang menampilkan nama kategori
      appBar: AppBar(
        title: Text(
          categoryName,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // 2. MENGGUNAKAN STREAMBUILDER UNTUK MENAMPILKAN DATA
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Belum ada koleksi di kategori ini.',
                style: GoogleFonts.montserrat(fontSize: 18),
              ),
            );
          }

          final documents = snapshot.data!.docs;
          return ListView.builder(
            itemCount: documents.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final doc = documents[index];
              final data = doc.data()! as Map<String, dynamic>;
              final itemData = _createDataModel(categoryName, data);

              // Tampilan kartu untuk setiap item
              return GestureDetector(
                onTap: () {
                  if (itemData != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => _createDetailScreen(itemData)),
                    );
                  }
                },
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(23),
                  ),
                  child: Stack(
                    children: [
                      Image.network(
                        data['imageUrl'] ??
                            'https://placehold.co/600x400/EEE/31343C',
                        width: 380,
                        height: 300,
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
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                          ),
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
        },
      ),
    );
  }
}
