import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailSliverAppBar<T> extends StatelessWidget {
  final T data;
  final String Function(T) getImageUrl;
  final String Function(T) getCategoryIconPath;
  final String Function(T) getTitle; // <-- PERBAIKAN: Parameter ditambahkan
  final Widget favoriteButton;

  const DetailSliverAppBar({
    Key? key,
    required this.data,
    required this.getImageUrl,
    required this.getCategoryIconPath,
    required this.getTitle, // <-- PERBAIKAN: Parameter ditambahkan
    required this.favoriteButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      systemOverlayStyle:
          const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
      expandedHeight: 300.0,
      pinned: true,

      // Mengatur warna AppBar saat menyusut agar sesuai dengan tema
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      elevation: 1,

      // Tombol kembali di kiri (akan selalu terlihat)
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.8),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),

      // Tombol-tombol di kanan (akan selalu terlihat)
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: favoriteButton,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 12, 8),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.8),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child:
                  Image.asset(getCategoryIconPath(data), width: 28, height: 28),
            ),
          ),
        ),
      ],

      // Bagian yang bisa menyusut
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16, right: 120),
        title: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final isCollapsed = constraints.maxHeight <= kToolbarHeight + 50;
            return isCollapsed
                ? Text(
                    getTitle(data),
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).appBarTheme.foregroundColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  )
                : const SizedBox.shrink();
          },
        ),
        background: Image.network(
          getImageUrl(data),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
