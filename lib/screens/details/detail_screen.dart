import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:museum_tugasakhir/screens/details/appbar.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:museum_tugasakhir/services/firestore_service.dart';

class DetailScreen<T> extends StatefulWidget {
  final T data;
  final String Function(T) getTitle;
  final String Function(T) getYear;
  final String Function(T) getDescription;
  final String Function(T) getImageUrl;
  final List<String> Function(T) getImageUrls;
  final String Function(T) getCategoryIconPath;
  final String Function(T) getItemId;
  final Map<String, dynamic> Function(T) toMap;

  const DetailScreen({
    Key? key,
    required this.data,
    required this.getTitle,
    required this.getYear,
    required this.getDescription,
    required this.getImageUrl,
    required this.getImageUrls,
    required this.getCategoryIconPath,
    required this.getItemId,
    required this.toMap,
  }) : super(key: key);

  @override
  _DetailScreenState<T> createState() => _DetailScreenState<T>();
}

class _DetailScreenState<T> extends State<DetailScreen<T>> {
  final FirestoreService _firestoreService = FirestoreService();
  final _commentController = TextEditingController();

  // Controller dan state untuk galeri gambar di bawah
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page?.round() != _currentPage) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _pageController.dispose();
    super.dispose();
  }

// --- FUNGSI BARU UNTUK LENCANA ---

  /// Fungsi untuk menampilkan dialog saat lencana baru didapatkan.
  void _showBadgeAwardedDialog(DocumentSnapshot badgeDoc) {
    final badgeData = badgeDoc.data() as Map<String, dynamic>;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(FontAwesomeIcons.award, color: Colors.orange[700]),
            const SizedBox(width: 10),
            const Text('Pencapaian Baru!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Selamat, Anda mendapatkan lencana:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              badgeData['name'] ?? 'Lencana Baru',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              badgeData['description'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keren!'),
          ),
        ],
      ),
    );
  }

  /// Fungsi untuk memeriksa apakah ada lencana baru yang didapat.
  void _checkAndShowBadge(Future<DocumentSnapshot?> badgeFuture) async {
    final badgeDoc = await badgeFuture;
    if (badgeDoc != null && mounted) {
      _showBadgeAwardedDialog(badgeDoc);
    }
  }

  /// Melacak bahwa pengguna telah melihat halaman ini.
  void _trackView() {
    // Menunggu sebentar agar Provider siap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<User?>(context, listen: false);
      if (user != null) {
        final future = _firestoreService.trackDetailView(
            user.uid, widget.getItemId(widget.data));
        _checkAndShowBadge(future);
      }
    });
  }

//Fungsi untuk memformat timestamp menjadi tanggal
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat('d MMMM yyyy', 'id_ID').format(timestamp.toDate());
  }

  void _handleFavoriteTap(User? user, bool isFavorited) {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Anda harus login untuk menambahkan ke favorit.')),
      );
    } else {
      _firestoreService.toggleFavorite(
        user.uid,
        widget.getItemId(widget.data),
        widget.toMap(widget.data),
      );
      final message = isFavorited
          ? '${widget.getTitle(widget.data)} dihapus dari favorit'
          : '${widget.getTitle(widget.data)} ditambahkan ke favorit';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

      _checkAndShowBadge(_firestoreService.trackFavoriteAction(user.uid));
      _checkAndShowBadge(_firestoreService.trackActiveVisitor(
          user.uid, widget.getItemId(widget.data)));
    }
  }

  //Fungsi untuk menampilkan gambar zoomable
  void _showZoomableImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87, // Latar belakang semi-transparan
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // Widget untuk zoom dan pan gambar
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(imageUrl),
              ),
              // Tombol close di pojok kanan atas
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.close, color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _postComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login untuk berkomentar.')),
      );
      return;
    }

    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    final T currentItem = widget.data;
    await FirebaseFirestore.instance.collection('comments').add({
      'itemId': widget.getItemId(currentItem),
      'text': commentText,
      'authorName': user.displayName ?? 'Pengguna Anonim',
      'authorId': user.uid,
      'authorEmail': user.email ?? 'Tidak ada email',
      'timestamp': FieldValue.serverTimestamp(),
      'itemTitle': widget.getTitle(currentItem),
      'itemImageUrl': widget.getImageUrl(currentItem),
    });

    _commentController.clear();
    FocusScope.of(context).unfocus();

    // Cek lencana setelah berkomentar
    _checkAndShowBadge(_firestoreService.trackCommentPost(
        user.uid, widget.getItemId(widget.data)));
    _checkAndShowBadge(_firestoreService.trackActiveVisitor(
        user.uid, widget.getItemId(widget.data)));
  }

  // Widget untuk membuat titik-titik indikator galeri
  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final itemId = widget.getItemId(widget.data);
    final imageUrls = widget.getImageUrls(widget.data);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          StreamBuilder<bool>(
            stream: user != null
                ? _firestoreService.isFavoritedStream(user.uid, itemId)
                : Stream.value(false),
            builder: (context, snapshot) {
              final isFavorited = snapshot.data ?? false;
              final favoriteButton = CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.8),
                child: IconButton(
                  icon: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: isFavorited ? Colors.red : Colors.black,
                  ),
                  onPressed: () => _handleFavoriteTap(user, isFavorited),
                ),
              );

              return DetailSliverAppBar(
                data: widget.data,
                // Mengirim satu gambar utama ke AppBar
                getImageUrl: widget.getImageUrl,
                getCategoryIconPath: widget.getCategoryIconPath,
                favoriteButton: favoriteButton,
                getTitle: widget.getTitle,
              );
            },
          ),

          //BAGIAN DESKRIPSI & KONTEN LAINNYA
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Deskripsi Item
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.getTitle(widget.data),
                          style: GoogleFonts.montserrat(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        widget.getYear(widget.data),
                        style: GoogleFonts.montserrat(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  const Divider(),
                  const SizedBox(height: 16.0),
                  Text(
                    widget.getDescription(widget.data),
                    style: GoogleFonts.montserrat(fontSize: 14, height: 1.5),
                  ),

                  //GALERI GAMBAR
                  if (imageUrls.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Galeri Gambar',
                        style: GoogleFonts.montserrat(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200, // Tinggi galeri
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: GestureDetector(
                              onTap: () {
                                _showZoomableImage(context, imageUrls[index]);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  imageUrls[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Indikator Titik-titik
                    if (imageUrls.length > 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(imageUrls.length, (index) {
                          return _buildPageIndicator(index == _currentPage);
                        }),
                      )
                  ],
                  //BAGIAN KOMENTAR
                  const Divider(height: 40),
                  Text('Komentar',
                      style: GoogleFonts.montserrat(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (user != null)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'Tulis komentar...',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _postComment,
                        ),
                      ],
                    )
                  else
                    const Text('Silakan login untuk berkomentar.'),
                  const SizedBox(height: 20),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('comments')
                        .where('itemId', isEqualTo: itemId)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const Center(child: CircularProgressIndicator());
                      if (snapshot.data!.docs.isEmpty)
                        return const Center(
                            child: Text('Jadilah yang pertama berkomentar!'));

                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final commentData = snapshot.data!.docs[index].data()
                              as Map<String, dynamic>;
                          // Ambil data timestamp
                          final timestamp =
                              commentData['timestamp'] as Timestamp?;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading:
                                  const Icon(Icons.account_circle, size: 40),
                              title: Text(commentData['authorName'] ?? 'Anonim',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(commentData['text'] ?? ''),
                              //Menampilkan tanggal di sini
                              trailing: Text(
                                _formatTimestamp(timestamp),
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
