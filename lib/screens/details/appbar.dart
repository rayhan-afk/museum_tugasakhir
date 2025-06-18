import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DetailSliverAppBar<T> extends StatelessWidget {
  final T data;
  final String Function(T) getImage;
  final String Function(T) getCategoryIconPath;

  const DetailSliverAppBar({
    Key? key,
    required this.data,
    required this.getImage,
    required this.getCategoryIconPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      systemOverlayStyle:
          const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
      expandedHeight: 275.0,
      backgroundColor: Colors.transparent, // Dibuat transparan
      elevation: 0.0,
      pinned: true,
      stretch: true,

      // Menambahkan title kosong. Ini adalah 'trik' untuk membuat Flutter
      // secara otomatis menempatkan leading dan actions di tengah vertikal AppBar.
      title: const Text(''),
      centerTitle: true,

      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.9),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.9),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child:
                  Image.asset(getCategoryIconPath(data), width: 28, height: 28),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          getImage(data),
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : const Center(child: CircularProgressIndicator()),
          errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
        ),
        stretchModes: const [
          StretchMode.blurBackground,
          StretchMode.zoomBackground,
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: Container(
          height: 32.0,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32.0),
              topRight: Radius.circular(32.0),
            ),
          ),
          child: Container(
            width: 40.0,
            height: 5.0,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(100.0),
            ),
          ),
        ),
      ),
    );
  }
}
