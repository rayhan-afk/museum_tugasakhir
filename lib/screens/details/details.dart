import 'package:flutter/material.dart';
// Ganti 'museum_tugasakhir' dengan nama folder proyek Anda
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
      getImage: (data) => data.imageUrl,
      // Di sinilah kita tentukan path ikonnya secara statis
      getCategoryIconPath: (data) => 'assets/image/artefak.png',
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
      getImage: (data) => data.imageUrl,
      // Di sini kita tentukan path ikon untuk Batuan
      getCategoryIconPath: (data) => 'assets/image/batuan.png',
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
      getImage: (data) => data.imageUrl,
      // Di sini kita tentukan path ikon untuk Fosil
      getCategoryIconPath: (data) => 'assets/image/fosil.png',
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
      getImage: (data) => data.imageUrl,
      // Di sini kita tentukan path ikon untuk Mineral
      getCategoryIconPath: (data) => 'assets/image/mineral.png',
    );
  }
}
