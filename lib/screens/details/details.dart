import 'package:flutter/material.dart';
// Ganti 'museum_tugasakhir' dengan nama proyek Anda
import 'package:museum_tugasakhir/data/data.dart';
import 'package:museum_tugasakhir/screens/details/detailscreen.dart';

// --- Wrapper untuk Artefak ---
class ArtefakDetailScreen extends StatelessWidget {
  final ArtefakData artefakData;
  const ArtefakDetailScreen({Key? key, required this.artefakData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DetailScreen<ArtefakData>(
      data: artefakData,
      getTitle: (data) => data.title,
      getYear: (data) => data.year,
      getDescription: (data) => data.description,
      getImageUrl: (data) => data.imageUrl, // Menggunakan 'imageUrl'
      getCategoryIconPath: (data) => 'assets/image/artefak.png',
      getItemId: (data) => data.id, // DITAMBAHKAN: Mengirim ID item
      toMap: (data) => data.toMap(), // DITAMBAHKAN: Mengirim fungsi toMap
    );
  }
}

// --- Wrapper untuk Batuan ---
class BatuanDetailScreen extends StatelessWidget {
  final BatuanData batuanData;
  const BatuanDetailScreen({Key? key, required this.batuanData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DetailScreen<BatuanData>(
      data: batuanData,
      getTitle: (data) => data.title,
      getYear: (data) => data.year,
      getDescription: (data) => data.description,
      getImageUrl: (data) => data.imageUrl, // Menggunakan 'imageUrl'
      getCategoryIconPath: (data) => 'assets/image/batuan.png',
      getItemId: (data) => data.id, // DITAMBAHKAN: Mengirim ID item
      toMap: (data) => data.toMap(), // DITAMBAHKAN: Mengirim fungsi toMap
    );
  }
}

// --- Wrapper untuk Fosil ---
class FosilDetailScreen extends StatelessWidget {
  final FosilData fosilData;
  const FosilDetailScreen({Key? key, required this.fosilData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DetailScreen<FosilData>(
      data: fosilData,
      getTitle: (data) => data.title,
      getYear: (data) => data.year,
      getDescription: (data) => data.description,
      getImageUrl: (data) => data.imageUrl, // Menggunakan 'imageUrl'
      getCategoryIconPath: (data) => 'assets/image/fosil.png',
      getItemId: (data) => data.id, // DITAMBAHKAN: Mengirim ID item
      toMap: (data) => data.toMap(), // DITAMBAHKAN: Mengirim fungsi toMap
    );
  }
}

// --- Wrapper untuk Mineral ---
class MineralDetailScreen extends StatelessWidget {
  final MineralData mineralData;
  const MineralDetailScreen({Key? key, required this.mineralData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DetailScreen<MineralData>(
      data: mineralData,
      getTitle: (data) => data.title,
      getYear: (data) => data.year,
      getDescription: (data) => data.description,
      getImageUrl: (data) => data.imageUrl, // Menggunakan 'imageUrl'
      getCategoryIconPath: (data) => 'assets/image/mineral.png',
      getItemId: (data) => data.id, // DITAMBAHKAN: Mengirim ID item
      toMap: (data) => data.toMap(), // DITAMBAHKAN: Mengirim fungsi toMap
    );
  }
}
