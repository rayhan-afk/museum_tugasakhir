import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Ganti 'museum_tugasakhir' dengan nama proyek Anda
import 'package:museum_tugasakhir/data/data.dart';
import 'package:museum_tugasakhir/screens/details/details.dart';
import 'package:museum_tugasakhir/services/firestore_service.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  // --- Fungsi pembantu untuk navigasi dan data model ---
  Widget _createDetailScreen(Object data) {
    if (data is ArtefakData) return ArtefakDetailScreen(artefakData: data);
    if (data is BatuanData) return BatuanDetailScreen(batuanData: data);
    if (data is FosilData) return FosilDetailScreen(fosilData: data);
    if (data is MineralData) return MineralDetailScreen(mineralData: data);
    return const Scaffold(body: Center(child: Text('Tipe data tidak valid')));
  }

  Object? _createDataModel(Map<String, dynamic> firestoreData, String docId) {
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

  @override
  Widget build(BuildContext context) {
    // Mendapatkan pengguna yang sedang login dari Provider
    final user = Provider.of<User?>(context);

    // Jika pengguna belum login, tampilkan pesan
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Favorit Saya')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Silakan login terlebih dahulu untuk melihat koleksi favorit Anda.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(fontSize: 18),
            ),
          ),
        ),
      );
    }

    // Jika sudah login, tampilkan daftar favorit dari Firestore
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorit Saya',
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Menggunakan stream dari FirestoreService untuk mendapatkan daftar favorit
        stream: FirestoreService().getFavoritesStream(user.uid),
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
                'Anda belum memiliki koleksi favorit.',
                style: GoogleFonts.montserrat(fontSize: 18),
              ),
            );
          }

          // Tampilan daftar sama seperti halaman kategori
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data()! as Map<String, dynamic>;
              // Membuat objek data dari data favorit
              final itemData = _createDataModel(data, doc.id);

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
                child: Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15.0),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: NetworkImage(data['imageUrl'] ?? ''),
                    ),
                    title: Text(data['title'] ?? 'Tanpa Judul',
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold)),

                    // # PERUBAHAN: Menampilkan deskripsi di subtitle
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(
                        data['description'] ?? 'Tidak ada deskripsi.',
                        maxLines: 2, // Batasi deskripsi hanya 2 baris
                        overflow: TextOverflow
                            .ellipsis, // Tambahkan '...' jika teks terlalu panjang
                        style: GoogleFonts.montserrat(),
                      ),
                    ),
                    isThreeLine:
                        true, // Izinkan ListTile untuk memiliki 3 baris
                    trailing: const Icon(Icons.chevron_right),
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
