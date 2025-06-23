// File: lib/screens/details/detailscreen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:museum_tugasakhir/screens/details/appbar.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Ganti 'museum_tugasakhir' dengan nama proyek Anda
import 'package:museum_tugasakhir/services/firestore_service.dart';
import 'package:museum_tugasakhir/data/data.dart';

class DetailScreen<T> extends StatefulWidget {
  final T data;
  final String Function(T) getTitle;
  final String Function(T) getYear;
  final String Function(T) getDescription;
  final String Function(T) getImageUrl;
  final String Function(T) getCategoryIconPath;
  final String Function(T) getItemId;
  final Map<String, dynamic> Function(T) toMap;

  const DetailScreen({
    Key? key,
    required this.data,
    required this.getTitle,
    required this.getYear,
    required this.getDescription,
    required this.getImageUrl,
    required this.getCategoryIconPath,
    required this.getItemId,
    required this.toMap,
  }) : super(key: key);

  @override
  _DetailScreenState<T> createState() => _DetailScreenState<T>();
}

class _DetailScreenState<T> extends State<DetailScreen<T>> {
  final FirestoreService _firestoreService = FirestoreService();
  // Controller untuk mengelola input teks pada kolom komentar
  final _commentController = TextEditingController();

  @override
  void dispose() {
    // Selalu dispose controller saat widget tidak lagi digunakan untuk mencegah memory leak
    _commentController.dispose();
    super.dispose();
  }

  void _handleFavoriteTap(User? user, bool isFavorited) {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Anda harus login untuk menambahkan ke favorit.')),
      );
    } else {
      _firestoreService.toggleFavorite(
        user.uid,
        widget.getItemId(widget.data),
        widget.toMap(widget.data),
      );
      final message = isFavorited
          ? '${widget.getTitle(widget.data)} dihapus dari favorit'
          : '${widget.getTitle(widget.data)} ditambahkan ke favorit';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  // --- FUNGSI BARU UNTUK MENGIRIM KOMENTAR ---
  Future<void> _postComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login untuk berkomentar.')),
      );
      return;
    }

    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) {
      return;
    }

    // Mengambil data item yang akan disimpan bersama komentar
    final T currentItem = widget.data;

    // Kirim data ke collection 'comments' di Firestore
    await FirebaseFirestore.instance.collection('comments').add({
      'itemId': widget.getItemId(currentItem),
      'text': commentText,
      'authorName': user.displayName ?? 'Pengguna Anonim',
      'authorId': user.uid,
      'timestamp': FieldValue.serverTimestamp(),

      // # PERUBAHAN: Tambahkan field-field ini
      'itemTitle': widget.getTitle(currentItem),
      'itemImageUrl': widget.getImageUrl(currentItem),
      'itemCategory': (widget
          .toMap(currentItem))['category'], // Ambil kategori dari toMap()
    });

    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final itemId = widget.getItemId(widget.data);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          // --- BAGIAN APPBAR & FAVORIT (Tidak Berubah) ---
          StreamBuilder<bool>(
            stream: user != null
                ? _firestoreService.isFavoritedStream(user.uid, itemId)
                : Stream.value(false),
            builder: (context, snapshot) {
              final bool isFavorited = snapshot.data ?? false;
              final favoriteButton = CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.9),
                child: IconButton(
                  icon: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: isFavorited ? Colors.red : Colors.black,
                  ),
                  onPressed: () => _handleFavoriteTap(user, isFavorited),
                ),
              );

              return DetailSliverAppBar(
                data: widget.data,
                getImageUrl: widget.getImageUrl,
                getCategoryIconPath: widget.getCategoryIconPath,
                favoriteButton: favoriteButton,
              );
            },
          ),

          // --- BAGIAN DESKRIPSI (Tidak Berubah) ---
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.getTitle(widget.data),
                          style: GoogleFonts.montserrat(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        widget.getYear(widget.data),
                        style: GoogleFonts.montserrat(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  const Divider(),
                  const SizedBox(height: 16.0),
                  Text(widget.getDescription(widget.data),
                      style: GoogleFonts.montserrat(fontSize: 14, height: 1.5)),
                ],
              ),
            ),
          ),

          // --- # PERUBAHAN: BAGIAN KOMENTAR DITAMBAHKAN DI SINI ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 40),
                  Text('Komentar',
                      style: GoogleFonts.montserrat(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Form untuk input komentar
                  if (user != null)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText:
                                  'Tulis komentar sebagai ${user.displayName}...',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _postComment,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8)),
                      child: const Text(
                          'Silakan login untuk dapat berkomentar.',
                          textAlign: TextAlign.center),
                    ),

                  const SizedBox(height: 20),

                  // Daftar komentar dari Firestore
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('comments')
                        .where('itemId', isEqualTo: itemId)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator()));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child:
                                    Text('Jadilah yang pertama berkomentar!')));
                      }
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true, // Wajib di dalam Column/ScrollView
                        physics:
                            const NeverScrollableScrollPhysics(), // Wajib agar tidak ada double scroll
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final commentData = snapshot.data!.docs[index].data()
                              as Map<String, dynamic>;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading:
                                  const Icon(Icons.account_circle, size: 40),
                              title: Text(commentData['authorName'] ?? 'Anonim',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(commentData['text'] ?? ''),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 40), // Beri jarak di bagian bawah
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

//Rayhan Abduhuda - 193040044
