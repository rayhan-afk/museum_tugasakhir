import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  void _handleFavoriteTap(User? user, bool isFavorited) {
    // # PERUBAHAN UTAMA ADA DI SINI
    if (user == null) {
      // Jika belum login, tampilkan pesan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus login untuk menambahkan ke favorit.'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Jika sudah login, panggil fungsi toggleFavorite
      _firestoreService.toggleFavorite(
        user.uid,
        widget.getItemId(widget.data),
        widget.toMap(widget.data),
      );

      // Tampilkan pesan pop-up berdasarkan status favorit sebelumnya
      final message = isFavorited
          ? '${widget.getTitle(widget.data)} dihapus dari favorit'
          : '${widget.getTitle(widget.data)} ditambahkan ke favorit';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final itemId = widget.getItemId(widget.data);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          // Gunakan StreamBuilder untuk mendapatkan status favorit secara real-time
          StreamBuilder<bool>(
            stream: user != null
                ? _firestoreService.isFavoritedStream(user.uid, itemId)
                : Stream.value(false),
            builder: (context, snapshot) {
              final bool isFavorited = snapshot.data ?? false;

              // Buat tombol favorit berdasarkan status
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
                  Text(
                    widget.getDescription(widget.data),
                    style: GoogleFonts.montserrat(fontSize: 14, height: 1.5),
                  ),
                  // Tambahkan bagian komentar Anda di sini
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
