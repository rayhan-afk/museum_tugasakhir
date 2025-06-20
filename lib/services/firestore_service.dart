import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Membuat instance dari Firestore
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Mendapatkan koleksi 'users'
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _db.collection('users');

  // --- FUNGSI UTAMA UNTUK FITUR FAVORIT ---

  /// Menambah atau menghapus item dari favorit pengguna.
  ///
  /// [userId] adalah ID pengguna yang sedang login.
  /// [itemId] adalah ID unik dari item koleksi yang akan difavoritkan.
  /// [itemData] adalah data lengkap dari item tersebut (dalam bentuk Map).
  Future<void> toggleFavorite(
      String userId, String itemId, Map<String, dynamic> itemData) async {
    // Menunjuk ke dokumen favorit spesifik untuk pengguna dan item ini.
    // Strukturnya: users -> {userId} -> favorites -> {itemId}
    final docRef =
        _usersCollection.doc(userId).collection('favorites').doc(itemId);

    // Mengecek apakah dokumen tersebut sudah ada atau belum.
    final doc = await docRef.get();

    if (doc.exists) {
      // Jika dokumen sudah ada, berarti item ini sudah difavoritkan.
      // Kita akan menghapusnya untuk "unfavorite".
      await docRef.delete();
    } else {
      // Jika dokumen belum ada, berarti item ini belum difavoritkan.
      // Kita akan membuatnya untuk "favorite".
      // Kita menyimpan itemData lengkap agar nanti mudah saat membuat halaman 'Koleksi Favorit'.
      await docRef.set(itemData);
    }
  }

  /// Stream untuk mendengarkan status favorit sebuah item secara real-time.
  ///
  /// Mengembalikan `true` jika item sudah difavoritkan, dan `false` jika belum.
  Stream<bool> isFavoritedStream(String userId, String itemId) {
    // Menunjuk ke dokumen favorit yang sama.
    final docRef =
        _usersCollection.doc(userId).collection('favorites').doc(itemId);

    // snapshots() akan mengirim update setiap kali ada perubahan pada dokumen ini.
    // .map() mengubah hasil snapshot menjadi nilai boolean sederhana.
    return docRef.snapshots().map((snapshot) => snapshot.exists);
  }

  // --- FUNGSI UNTUK HALAMAN KOLEKSI FAVORIT (NANTI) ---

  /// Stream untuk mendapatkan semua item favorit dari seorang pengguna.
  Stream<QuerySnapshot<Map<String, dynamic>>> getFavoritesStream(
      String userId) {
    return _usersCollection
        .doc(userId)
        .collection('favorites')
        .orderBy('addedAt',
            descending: true) // Urutkan dari yang terbaru ditambahkan
        .snapshots();
  }
}
