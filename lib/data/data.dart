import 'package:cloud_firestore/cloud_firestore.dart';

//Artefak
class ArtefakData {
  final String id;
  final String title;
  final String year;
  final String description;
  final String imageUrl; // Untuk gambar sampul/thumbnail
  final List<String> imageUrls; // Untuk galeri gambar

  const ArtefakData({
    required this.id,
    required this.title,
    required this.year,
    required this.description,
    required this.imageUrl,
    required this.imageUrls,
  });

  // Factory constructor untuk membuat objek dari data Firestore
  factory ArtefakData.fromFirestore(Map<String, dynamic> data, String docId) {
    // Mengambil data array dari Firestore dan mengubahnya menjadi List<String>
    final List<dynamic> urlsFromServer = data['imageUrls'] ?? [];
    final List<String> parsedUrls = List<String>.from(urlsFromServer);

    return ArtefakData(
      id: docId,
      title: data['title'] ?? 'Tanpa Judul',
      year: data['year'] ?? 'Tahun Tidak Diketahui',
      description: data['description'] ?? 'Tidak ada deskripsi.',
      imageUrl: data['imageUrl'] ?? '', // Ambil URL gambar sampul
      imageUrls: parsedUrls, // Ambil daftar URL untuk galeri
    );
  }

  // Fungsi untuk mengubah objek ini menjadi Map agar bisa disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'year': year,
      'description': description,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'category': 'Artefak',
      'addedAt': FieldValue.serverTimestamp(),
    };
  }
}

//Batuan
class BatuanData {
  final String id;
  final String title;
  final String year;
  final String description;
  final String imageUrl;
  final List<String> imageUrls;

  const BatuanData({
    required this.id,
    required this.title,
    required this.year,
    required this.description,
    required this.imageUrl,
    required this.imageUrls,
  });

  factory BatuanData.fromFirestore(Map<String, dynamic> data, String docId) {
    final List<dynamic> urlsFromServer = data['imageUrls'] ?? [];
    final List<String> parsedUrls = List<String>.from(urlsFromServer);
    return BatuanData(
      id: docId,
      title: data['title'] ?? 'Tanpa Judul',
      year: data['year'] ?? 'Tahun Tidak Diketahui',
      description: data['description'] ?? 'Tidak ada deskripsi.',
      imageUrl: data['imageUrl'] ?? '',
      imageUrls: parsedUrls,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'year': year,
      'description': description,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'category': 'Batuan',
      'addedAt': FieldValue.serverTimestamp(),
    };
  }
}

//Fosil
class FosilData {
  final String id;
  final String title;
  final String year;
  final String description;
  final String imageUrl;
  final List<String> imageUrls;

  const FosilData({
    required this.id,
    required this.title,
    required this.year,
    required this.description,
    required this.imageUrl,
    required this.imageUrls,
  });

  factory FosilData.fromFirestore(Map<String, dynamic> data, String docId) {
    final List<dynamic> urlsFromServer = data['imageUrls'] ?? [];
    final List<String> parsedUrls = List<String>.from(urlsFromServer);
    return FosilData(
      id: docId,
      title: data['title'] ?? 'Tanpa Judul',
      year: data['year'] ?? 'Tahun Tidak Diketahui',
      description: data['description'] ?? 'Tidak ada deskripsi.',
      imageUrl: data['imageUrl'] ?? '',
      imageUrls: parsedUrls,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'year': year,
      'description': description,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'category': 'Fosil',
      'addedAt': FieldValue.serverTimestamp(),
    };
  }
}

//Mineral
class MineralData {
  final String id;
  final String title;
  final String year;
  final String description;
  final String imageUrl;
  final List<String> imageUrls;

  const MineralData({
    required this.id,
    required this.title,
    required this.year,
    required this.description,
    required this.imageUrl,
    required this.imageUrls,
  });

  factory MineralData.fromFirestore(Map<String, dynamic> data, String docId) {
    final List<dynamic> urlsFromServer = data['imageUrls'] ?? [];
    final List<String> parsedUrls = List<String>.from(urlsFromServer);
    return MineralData(
      id: docId,
      title: data['title'] ?? 'Tanpa Judul',
      year: data['year'] ?? 'Tahun Tidak Diketahui',
      description: data['description'] ?? 'Tidak ada deskripsi.',
      imageUrl: data['imageUrl'] ?? '',
      imageUrls: parsedUrls,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'year': year,
      'description': description,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'category': 'Mineral',
      'addedAt': FieldValue.serverTimestamp(),
    };
  }
}
