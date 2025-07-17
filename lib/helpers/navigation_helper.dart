// File: lib/helpers/navigation_helper.dart
// TUGAS: Menjadi pusat untuk semua fungsi pembantu yang berhubungan
// dengan pembuatan model data dan navigasi ke halaman detail.

import 'package:flutter/material.dart';

// Ganti 'museum_tugasakhir' dengan nama proyek Anda
import 'package:museum_tugasakhir/data/data.dart';
import 'package:museum_tugasakhir/screens/details/details.dart';

// Fungsi ini sekarang menjadi top-level dan bisa diakses dari mana saja.
// Garis bawah (_) dihilangkan agar tidak lagi bersifat pribadi.

/// Memilih halaman detail yang benar untuk dibuka berdasarkan tipe data.
Widget createDetailScreen(Object data) {
  if (data is ArtefakData) {
    return ArtefakDetailScreen(artefakData: data);
  } else if (data is BatuanData) {
    return BatuanDetailScreen(batuanData: data);
  } else if (data is FosilData) {
    return FosilDetailScreen(fosilData: data);
  } else if (data is MineralData) {
    return MineralDetailScreen(mineralData: data);
  }
  // Fallback jika tipe data tidak dikenali
  return const Scaffold(body: Center(child: Text('Tipe data tidak valid')));
}

/// Mengubah data mentah (Map) dari Firestore menjadi objek data yang benar.
Object? createDataModel(
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
