import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:museum_tugasakhir/services/firestore_service.dart';

class MuseumScreen extends StatefulWidget {
  const MuseumScreen({super.key});

  @override
  State<MuseumScreen> createState() => _MuseumScreenState();
}

class _MuseumScreenState extends State<MuseumScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  late Future<DocumentSnapshot<Map<String, dynamic>>> _museumInfoFuture;

  @override
  void initState() {
    super.initState();
    _museumInfoFuture = FirebaseFirestore.instance
        .collection('museum_info')
        .doc('info_utama')
        .get();

    _pageController.addListener(() {
      if (_pageController.page != null &&
          _pageController.page!.round() != _currentPage) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildInfoTile(
      BuildContext context, IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showZoomableImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(imageUrl),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.close, color: Colors.black),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: _currentPage == index ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // Widget untuk menampilkan kartu statistik angka
  Widget _buildStatsCard(BuildContext context, IconData icon, String title,
      Future<AggregateQuerySnapshot> future) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon,
                  size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(title,
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              FutureBuilder<AggregateQuerySnapshot>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 29,
                      child: Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Text('N/A',
                        style: GoogleFonts.montserrat(
                            fontSize: 24, fontWeight: FontWeight.bold));
                  }
                  return Text(
                    (snapshot.data?.count ?? 0).toString(),
                    style: GoogleFonts.montserrat(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // # FUNGSI BARU: Widget untuk menampilkan kartu Penjelajah Teratas
  Widget _buildTopExplorerCard(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirestoreService().getTopExplorerStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                    height: 95, // Sesuaikan tinggi agar konsisten
                    child: Center(child: CircularProgressIndicator()));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SizedBox(
                    height: 95, child: Center(child: Text('Belum ada data')));
              }

              final topUser = snapshot.data!.docs.first.data();
              return Column(
                children: [
                  Icon(Icons.military_tech,
                      size: 32, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 8),
                  Text(
                    'Penjelajah Teratas',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    topUser['userName'] ?? '...',
                    style: GoogleFonts.montserrat(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _museumInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(child: Text('Gagal memuat data museum.'));
          }

          final data = snapshot.data!.data()!;
          final namaMuseum = data['nama_museum'] ?? 'Museum Geologi';
          final alamat = data['alamat'] ?? 'Alamat tidak tersedia';
          final deskripsi =
              data['deskripsi_umum'] ?? 'Deskripsi tidak tersedia';
          final jamOperasional =
              data['jam_operasional'] ?? 'Jam operasional tidak tersedia';
          final headerImageUrl = data['imageUrl'] as String?;
          final List<dynamic> galleryUrlsRaw = data['imageUrls'] ?? [];
          final List<String> galleryUrls = List<String>.from(galleryUrlsRaw);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250.0,
                pinned: true,
                stretch: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    namaMuseum,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        const Shadow(blurRadius: 8, color: Colors.black54)
                      ],
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 56.0, bottom: 16.0),
                  background:
                      headerImageUrl != null && headerImageUrl.isNotEmpty
                          ? Image.network(
                              headerImageUrl,
                              fit: BoxFit.cover,
                              color: Colors.black.withOpacity(0.4),
                              colorBlendMode: BlendMode.darken,
                            )
                          : Container(color: Colors.grey),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoTile(context, Icons.location_on_outlined,
                          'Alamat', alamat),
                      const Divider(height: 24),
                      _buildInfoTile(context, Icons.access_time_outlined,
                          'Jam Operasional', jamOperasional),
                      const Divider(height: 24),
                      _buildInfoTile(
                          context, Icons.info_outline, 'Deskripsi', deskripsi),

                      if (galleryUrls.isNotEmpty) ...[
                        const SizedBox(height: 30),
                        Text(
                          'Galeri',
                          style: GoogleFonts.montserrat(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: PageView.builder(
                            dragStartBehavior: DragStartBehavior.start,
                            controller: _pageController,
                            itemCount: galleryUrls.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () => _showZoomableImage(
                                    context, galleryUrls[index]),
                                child: Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.network(
                                    galleryUrls[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(galleryUrls.length,
                              (index) => _buildPageIndicator(index)),
                        ),
                      ],

                      // # PERUBAHAN: Bagian Statistik Ditambahkan di Sini
                      const SizedBox(height: 30),
                      Text(
                        'Statistik & Pencapaian',
                        style: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatsCard(
                            context,
                            Icons.group_outlined,
                            'Total User Login',
                            FirebaseFirestore.instance
                                .collection('users')
                                .count()
                                .get(),
                          ),
                          const SizedBox(width: 16),
                          // Mengganti kartu pemain kuis dengan kartu penjelajah teratas
                          _buildTopExplorerCard(context),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
