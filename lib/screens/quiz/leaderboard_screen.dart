import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:museum_tugasakhir/services/firestore_service.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  // Fungsi untuk mendapatkan warna dan ikon medali berdasarkan peringkat
  Widget _getRankIcon(int rank) {
    IconData iconData;
    Color color;
    double radius;
    double iconSize;

    switch (rank) {
      case 1:
        iconData = FontAwesomeIcons.medal;
        color = const Color(0xFFFFD700); // Emas
        radius = 24; // Ukuran lebih besar untuk juara 1
        iconSize = 28;
        break;
      case 2:
        iconData = FontAwesomeIcons.medal;
        color = const Color(0xFFC0C0C0); // Perak
        radius = 22; // Sedikit lebih besar
        iconSize = 26;
        break;
      case 3:
        iconData = FontAwesomeIcons.medal;
        color = const Color(0xFFCD7F32); // Perunggu
        radius = 20; // Sedikit lebih besar
        iconSize = 24;
        break;
      default:
        // Untuk peringkat 4 ke atas, tampilkan angka biasa
        return CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey[200],
          child: Text(
            rank.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withOpacity(0.2),
      child: FaIcon(iconData, color: color, size: iconSize),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Papan Peringkat',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Menggunakan stream dari FirestoreService untuk mendapatkan daftar peringkat
        stream: FirestoreService().getLeaderboardStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Gagal memuat papan peringkat.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Belum ada pemain di papan peringkat.',
                style: GoogleFonts.montserrat(fontSize: 18),
              ),
            );
          }

          // Tampilkan daftar peringkat dalam ListView
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data()! as Map<String, dynamic>;
              final rank = index + 1;

              return Card(
                elevation: rank <= 3 ? 4 : 1, // Beri shadow lebih untuk top 3
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: rank == 1
                        ? const Color(0xFFFFD700)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  // Menampilkan ikon medali atau nomor peringkat
                  leading: _getRankIcon(rank),
                  // Menampilkan foto profil dan nama pengguna
                  title: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: data['userPhotoUrl'] != null &&
                                data['userPhotoUrl'].isNotEmpty
                            ? NetworkImage(data['userPhotoUrl'])
                            : null,
                        child: data['userPhotoUrl'] == null ||
                                data['userPhotoUrl'].isEmpty
                            ? const Icon(Icons.person, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          data['userName'] ?? 'Pemain Anonim',
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // Menampilkan skor
                  trailing: Text(
                    '${data['score'] ?? 0} Poin',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
