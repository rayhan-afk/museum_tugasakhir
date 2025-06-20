// File: lib/screens/details/search.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

// Import helper dan model data yang diperlukan
// Ganti 'museum_tugasakhir' dengan nama proyek Anda
import 'package:museum_tugasakhir/data/data.dart';
import 'package:museum_tugasakhir/screens/details/details.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = ""; // Untuk menyimpan teks yang diketik pengguna

  // --- Fungsi pembantu untuk navigasi detail ---
  Widget _createDetailScreen(Object data) {
    if (data is ArtefakData) return ArtefakDetailScreen(artefakData: data);
    if (data is BatuanData) return BatuanDetailScreen(batuanData: data);
    if (data is FosilData) return FosilDetailScreen(fosilData: data);
    if (data is MineralData) return MineralDetailScreen(mineralData: data);
    return const Scaffold(body: Center(child: Text('Tipe data tidak valid')));
  }

  // --- Fungsi pembantu untuk membuat model data ---
  // # PERUBAHAN 1: Fungsi ini sekarang menerima ID Dokumen
  Object? _createDataModel(Map<String, dynamic> firestoreData, String docId) {
    final category = firestoreData['category'] as String?;
    if (category == null) return null;

    switch (category) {
      // # PERUBAHAN 2: ID Dokumen dikirim saat membuat objek data
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Kolom input pencarian (tidak berubah)
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Cari koleksi...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
            ),
          ),
        ),
      ),
      body: _searchQuery.isEmpty
          ? Center(
              // Tampilan awal (tidak berubah)
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 80, color: Colors.grey[300]),
                  Text(
                    'Ketik untuk mencari koleksi museum.',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              // Query pencarian awalan (tidak berubah)
              stream: FirebaseFirestore.instance
                  .collection('koleksi')
                  .where('search_keyword', isGreaterThanOrEqualTo: _searchQuery)
                  .where('search_keyword',
                      isLessThanOrEqualTo: '$_searchQuery\uf8ff')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada hasil untuk "$_searchQuery"',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                }

                // # PERUBAHAN 3: Tampilan hasil pencarian sekarang sama dengan halaman kategori
                return ListView(
                  padding: const EdgeInsets.all(10),
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data()! as Map<String, dynamic>;
                    // Memanggil _createDataModel dengan ID dokumen
                    final itemData = _createDataModel(data, doc.id);

                    return GestureDetector(
                      onTap: () {
                        if (itemData != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  _createDetailScreen(itemData),
                            ),
                          );
                        }
                      },
                      child: Container(
                        height: 300,
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
                              width: double.infinity,
                              height: 300,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) =>
                                  progress == null
                                      ? child
                                      : const Center(
                                          child: CircularProgressIndicator()),
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                      child:
                                          Icon(Icons.broken_image, size: 40)),
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
                  }).toList(),
                );
              },
            ),
    );
  }
}
