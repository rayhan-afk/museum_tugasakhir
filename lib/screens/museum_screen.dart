import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MuseumScreen extends StatelessWidget {
  const MuseumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Museum Geologi Bandung'),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        // Mengambil data dari Firestore
        // Perhatikan 'info_utama' adalah ID dokumen yang kita buat tadi
        future: FirebaseFirestore.instance
            .collection('museum_info')
            .doc('info_utama') // Ambil dokumen dengan ID 'info_utama'
            .get(),
        builder: (context, snapshot) {
          // Jika sedang loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Jika ada error
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}'); // Cetak error ke konsol
            return const Center(child: Text('Gagal memuat data.'));
          }

          // Jika data tidak ditemukan atau dokumen tidak ada
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Data museum tidak ditemukan.'));
          }

          // Jika data berhasil didapatkan
          if (snapshot.hasData) {
            // Ambil data dari snapshot
            // Pastikan untuk menggunakan Map<String, dynamic>
            Map<String, dynamic>? data = snapshot.data!.data();

            if (data == null) {
              return const Center(child: Text('Data museum kosong.'));
            }

            // Ambil masing-masing field
            String namaMuseum = data['nama_museum'] ?? 'Nama Tidak Tersedia';
            String alamat = data['alamat'] ?? 'Alamat Tidak Tersedia';
            String deskripsi =
                data['deskripsi_umum'] ?? 'Deskripsi Tidak Tersedia';
            String jamOperasional =
                data['jam_operasional'] ?? 'Jam Operasional Tidak Tersedia';
            String? urlGambar = data['url_gambar_museum']; // Bisa null

            // Tampilkan data dalam UI
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Tampilkan gambar jika ada URL
                  if (urlGambar != null && urlGambar.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        urlGambar,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        // Tambahkan errorBuilder untuk menangani jika gambar gagal dimuat
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(
                                child: Text('Gambar tidak bisa dimuat')),
                          );
                        },
                        // Tambahkan loadingBuilder untuk menampilkan indikator saat gambar dimuat
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  if (urlGambar != null && urlGambar.isNotEmpty)
                    const SizedBox(height: 16.0),

                  Text(
                    namaMuseum,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Alamat:',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(alamat, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 16.0),
                  Text(
                    'Deskripsi:',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(deskripsi, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 16.0),
                  Text(
                    'Jam Operasional:',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(jamOperasional,
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            );
          }

          // Default jika tidak ada kondisi yang terpenuhi (seharusnya tidak terjadi)
          return const Center(child: Text('Terjadi kesalahan.'));
        },
      ),
    );
  }
}
