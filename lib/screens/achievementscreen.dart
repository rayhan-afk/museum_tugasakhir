import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Ganti 'museum_tugasakhir' dengan nama proyek Anda
import 'package:museum_tugasakhir/services/firestore_service.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  // Fungsi helper untuk mengubah string nama ikon menjadi IconData
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'map-signs':
        return FontAwesomeIcons.mapSigns;
      case 'search':
        return FontAwesomeIcons.search;
      case 'route':
        return FontAwesomeIcons.route;
      case 'images':
        return FontAwesomeIcons.images;
      case 'graduation-cap':
        return FontAwesomeIcons.graduationCap;
      case 'comments':
        return FontAwesomeIcons.comments;
      case 'heart':
        return FontAwesomeIcons.solidHeart;
      case 'star':
        return FontAwesomeIcons.solidStar;
      default:
        return FontAwesomeIcons.questionCircle;
    }
  }

  // Fungsi helper untuk mengubah string hex menjadi Color
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pencapaian')),
        body: const Center(
          child: Text('Silakan login untuk melihat pencapaian Anda.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Pencapaian',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Bagian Header Profil Pengguna ---
            Container(
              padding: const EdgeInsets.all(24.0),
              width: double.infinity,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.displayName ?? 'Pengguna',
                    style: GoogleFonts.montserrat(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? '',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1),

            // --- Bagian Galeri Lencana ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirestoreService().getAllBadgesStream(),
                builder: (context, allBadgesSnapshot) {
                  if (allBadgesSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!allBadgesSnapshot.hasData ||
                      allBadgesSnapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('Tidak ada lencana yang tersedia.'));
                  }

                  final allBadges = allBadgesSnapshot.data!.docs;

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirestoreService().getEarnedBadgesStream(user.uid),
                    builder: (context, earnedBadgesSnapshot) {
                      final Set<String> earnedBadgeIds =
                          earnedBadgesSnapshot.hasData
                              ? earnedBadgesSnapshot.data!.docs
                                  .map((doc) => doc.id)
                                  .toSet()
                              : {};

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: allBadges.length,
                        itemBuilder: (context, index) {
                          final badgeDoc = allBadges[index];
                          final badgeData =
                              badgeDoc.data()! as Map<String, dynamic>;
                          final bool isEarned =
                              earnedBadgeIds.contains(badgeDoc.id);

                          final iconData =
                              _getIconData(badgeData['iconName'] ?? '');
                          final iconColor = _getColorFromHex(
                              badgeData['iconColor'] ?? '#000000');

                          // # PERUBAHAN: Widget dibungkus dengan Tooltip
                          return Tooltip(
                            message: badgeData['description'] ??
                                'Deskripsi tidak tersedia.',
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Opacity(
                              opacity: isEarned ? 1.0 : 0.3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 35,
                                    backgroundColor: iconColor
                                        .withOpacity(isEarned ? 0.15 : 0.05),
                                    child: FaIcon(iconData,
                                        color:
                                            isEarned ? iconColor : Colors.grey,
                                        size: 30),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    badgeData['name'] ?? 'Lencana',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
