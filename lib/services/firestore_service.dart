import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _koleksiCollection =>
      _db.collection('koleksi');

  /// Menambah atau menghapus item dari favorit pengguna menggunakan Transaction.
  Future<void> toggleFavorite(
      String userId, String itemId, Map<String, dynamic> itemData) async {
    final userFavoriteRef =
        _usersCollection.doc(userId).collection('favorites').doc(itemId);
    final mainItemRef = _koleksiCollection.doc(itemId);

    return _db.runTransaction((transaction) async {
      // # PERBAIKAN: Lakukan semua operasi BACA (get) terlebih dahulu
      final favoriteDoc = await transaction.get(userFavoriteRef);
      final mainItemDoc = await transaction.get(mainItemRef);

      if (favoriteDoc.exists) {
        // --- Jika item SUDAH difavoritkan (logika unfavorite) ---
        // Lakukan semua operasi TULIS (delete, update) setelah membaca
        transaction.delete(userFavoriteRef);

        final currentCount = mainItemDoc.data()?['favoriteCount'] ?? 0;
        if (currentCount > 0) {
          transaction
              .update(mainItemRef, {'favoriteCount': FieldValue.increment(-1)});
        }
      } else {
        // --- Jika item BELUM difavoritkan (logika favorite) ---
        // Lakukan semua operasi TULIS (set, update)
        transaction.set(userFavoriteRef, itemData);
        transaction
            .update(mainItemRef, {'favoriteCount': FieldValue.increment(1)});
      }
    });
  }

  /// Stream untuk mendengarkan status favorit sebuah item secara real-time. (Tidak Berubah)
  Stream<bool> isFavoritedStream(String userId, String itemId) {
    return _usersCollection
        .doc(userId)
        .collection('favorites')
        .doc(itemId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  /// Stream untuk mendapatkan semua item favorit dari seorang pengguna. (Tidak Berubah)
  Stream<QuerySnapshot<Map<String, dynamic>>> getFavoritesStream(
      String userId) {
    return _usersCollection
        .doc(userId)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots();
  }
}
