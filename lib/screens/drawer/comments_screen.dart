import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:museum_tugasakhir/data/data.dart';
import 'package:museum_tugasakhir/screens/details/details.dart';
import 'package:museum_tugasakhir/services/firestore_service.dart';

//Fungsi helper diletakkan di sini agar bisa dipakai bersama
Widget _createDetailScreen(Object data) {
  if (data is ArtefakData) return ArtefakDetailScreen(artefakData: data);
  if (data is BatuanData) return BatuanDetailScreen(batuanData: data);
  if (data is FosilData) return FosilDetailScreen(fosilData: data);
  if (data is MineralData) return MineralDetailScreen(mineralData: data);
  return const Scaffold(body: Center(child: Text('Tipe data tidak valid')));
}

Object? _createDataModel(
    String category, Map<String, dynamic> firestoreData, String docId) {
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

class MyCommentsScreen extends StatelessWidget {
  const MyCommentsScreen({Key? key}) : super(key: key);

  //Fungsi untuk menangani navigasi saat kartu komentar di-klik
  Future<void> _navigateToDetail(BuildContext context, String itemId) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('koleksi')
        .doc(itemId)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      final category = data['category'] ?? '';
      final itemData = _createDataModel(category, data, docSnapshot.id);

      if (itemData != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => _createDetailScreen(itemData)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Item koleksi ini mungkin sudah tidak tersedia.')),
      );
    }
  }

  //FUNGSI Untuk menampilkan dialog konfirmasi hapus
  void _showDeleteConfirmationDialog(BuildContext context, String commentId) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Hapus Komentar?'),
          content:
              const Text('Apakah Anda yakin ingin menghapus komentar ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(ctx).pop(); // Tutup dialog
              },
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // Panggil fungsi hapus dari service
                FirestoreService().deleteComment(commentId);
                Navigator.of(ctx).pop(); // Tutup dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Komentar Saya',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: user == null
          ? const Center(
              child: Text('Anda harus login untuk melihat halaman ini.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirestoreService().getMyCommentsStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text('Anda belum pernah berkomentar.',
                          style: GoogleFonts.montserrat(fontSize: 18)));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data()! as Map<String, dynamic>;
                    final imageUrl = data['itemImageUrl'] as String? ?? '';

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.fromLTRB(16, 12, 8, 12),
                        leading: SizedBox(
                          width: 60,
                          height: 60,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: imageUrl.isNotEmpty &&
                                    imageUrl.startsWith('http')
                                ? Image.network(imageUrl, fit: BoxFit.cover)
                                : const Icon(Icons.photo, color: Colors.grey),
                          ),
                        ),
                        title: Text(
                          '"${data['text'] ?? ''}"',
                          style: GoogleFonts.montserrat(
                              fontStyle: FontStyle.italic),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'pada: ${data['itemTitle'] ?? 'Koleksi'}',
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        isThreeLine: true,
                        // # PERUBAHAN: Menambahkan tombol hapus di trailing
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () =>
                              _showDeleteConfirmationDialog(context, doc.id),
                        ),
                        onTap: () => _navigateToDetail(context, data['itemId']),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
