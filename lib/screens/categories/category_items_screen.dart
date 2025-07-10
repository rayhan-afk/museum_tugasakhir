import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:museum_tugasakhir/data/data.dart';
import 'package:museum_tugasakhir/screens/details/details.dart';

class CategoryItemsScreen extends StatelessWidget {
  final String categoryName;

  const CategoryItemsScreen({Key? key, required this.categoryName})
      : super(key: key);

  // Fungsi helper untuk memilih halaman detail yang benar
  Widget _createDetailScreen(Object data) {
    if (data is ArtefakData) return ArtefakDetailScreen(artefakData: data);
    if (data is BatuanData) return BatuanDetailScreen(batuanData: data);
    if (data is FosilData) return FosilDetailScreen(fosilData: data);
    if (data is MineralData) return MineralDetailScreen(mineralData: data);
    return const Scaffold(body: Center(child: Text('Tipe data tidak valid')));
  }

  //Fungsi untuk menerima ID Dokumen
  Object? _createDataModel(
      String category, Map<String, dynamic> firestoreData, String docId) {
    switch (category) {
      //ID Dokumen dikirim saat membuat objek data
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
    final Query query = FirebaseFirestore.instance
        .collection('koleksi')
        .where('category', isEqualTo: categoryName);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          categoryName,
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold, color: Colors.black),
        ),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
              //Mengirim ID dokumen (doc.id) ke fungsi helper
              final itemData = _createDataModel(categoryName, data, doc.id);

              return GestureDetector(
                onTap: () {
                  if (itemData != null) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                _createDetailScreen(itemData)));
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
                                child: Icon(Icons.broken_image, size: 40)),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5)),
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
