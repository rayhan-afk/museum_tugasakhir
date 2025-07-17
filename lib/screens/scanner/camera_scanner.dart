import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:museum_tugasakhir/data/data.dart';
import 'package:museum_tugasakhir/helpers/navigation_helper.dart';
import 'package:museum_tugasakhir/screens/details/details.dart';
import 'package:museum_tugasakhir/services/firestore_service.dart';
import 'package:provider/provider.dart';

class CameraScannerPage extends StatefulWidget {
  const CameraScannerPage({Key? key}) : super(key: key);

  @override
  State<CameraScannerPage> createState() => _CameraScannerPageState();
}

class _CameraScannerPageState extends State<CameraScannerPage> {
  final MobileScannerController _scannerController = MobileScannerController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isProcessing = false;

// --- Fungsi untuk menampilkan dialog lencana baru ---
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
            Text('Selamat, Anda mendapatkan lencana:',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(
              badgeData['name'] ?? 'Lencana Baru',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      // Jeda sejenak sebelum menampilkan dialog lencana
      await Future.delayed(const Duration(milliseconds: 500));
      _showBadgeAwardedDialog(badgeDoc);
    }
  }

  //Fungsi untuk menampilkan dialog sukses ---
  Future<void> _showSuccessDialog(
      Map<String, dynamic> itemDataMap, Object itemDataObject) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Pengguna harus menekan tombol
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 10),
              Text('Berhasil Dipindai',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Koleksi berikut telah ditemukan:'),
                const SizedBox(height: 15),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      itemDataMap['imageUrl'] ?? '',
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  itemDataMap['title'] ?? 'Tanpa Judul',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Scan Lagi'),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
            ),
            ElevatedButton(
              child: const Text('Lihat Detail'),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                // Navigasi ke halaman detail
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            createDetailScreen(itemDataObject)));
              },
            ),
          ],
        );
      },
    );
  }

// --- Fungsi utama untuk memproses hasil scan ---
  void _processBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    final String? scannedId = capture.barcodes.first.rawValue;

    if (scannedId == null || scannedId.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Kode QR tidak valid.')));
      if (mounted)
        setState(() {
          _isProcessing = false;
        });
      return;
    }

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('koleksi')
          .doc(scannedId)
          .get();
      if (docSnapshot.exists && context.mounted) {
        final data = docSnapshot.data()!;
        final category = data['category'] ?? '';
        final itemData = createDataModel(category, data, docSnapshot.id);

        if (itemData != null) {
          await _scannerController.stop();

          // Lacak aktivitas scan untuk lencana
          final user = Provider.of<User?>(context, listen: false);
          if (user != null) {
            final badgeFuture =
                _firestoreService.trackQrScan(user.uid, scannedId);
            _checkAndShowBadge(badgeFuture);
          }

          await _showSuccessDialog(data, itemData);
          if (mounted) await _scannerController.start();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Koleksi tidak ditemukan.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Terjadi kesalahan saat mencari koleksi.')));
    }

    if (mounted)
      setState(() {
        _isProcessing = false;
      });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _processBarcode,
          ),
          Positioned.fill(
            child: Container(
              decoration: ShapeDecoration(
                shape: QrScannerOverlayShape(
                  borderColor: Colors.white,
                  borderWidth: 8,
                  cutOutSize: MediaQuery.of(context).size.width * 0.7,
                ),
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Text(
              'Arahkan kamera ke Kode QR',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(blurRadius: 10, color: Colors.black.withOpacity(0.7))
                ],
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 12,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET KUSTOM UNTUK MEMBUAT BENTUK OVERLAY SCANNER ---
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double overlayColorOpacity;
  final double borderRadius;
  final double cutOutSize;

  QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 8.0,
    this.overlayColorOpacity = 0.7,
    this.borderRadius = 12,
    required this.cutOutSize,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path.combine(
      PathOperation.difference,
      Path()..addRect(rect),
      Path()
        ..addRRect(RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: rect.center, width: cutOutSize, height: cutOutSize),
            Radius.circular(borderRadius))),
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final backgroundPaint = Paint()
      ..color = Color.fromRGBO(0, 0, 0, overlayColorOpacity)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: rect.center, width: cutOutSize, height: cutOutSize),
        Radius.circular(borderRadius));

    canvas.drawPath(getOuterPath(rect), backgroundPaint);
    canvas.drawRRect(boxRect, borderPaint);
  }

  @override
  ShapeBorder scale(double t) => this;
}
