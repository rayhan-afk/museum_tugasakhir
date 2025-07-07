// File: lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Mendapatkan referensi ke semua collection yang kita gunakan
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _koleksiCollection =>
      _db.collection('koleksi');
  CollectionReference<Map<String, dynamic>> get _commentsCollection =>
      _db.collection('comments');

  /// Menambah atau menghapus item dari favorit pengguna menggunakan Transaction.
  Future<void> toggleFavorite(
      String userId, String itemId, Map<String, dynamic> itemData) async {
    final userFavoriteRef =
        _usersCollection.doc(userId).collection('favorites').doc(itemId);
    final mainItemRef = _koleksiCollection.doc(itemId);

    return _db.runTransaction((transaction) async {
      final favoriteDoc = await transaction.get(userFavoriteRef);
      final mainItemDoc = await transaction.get(mainItemRef);

      if (favoriteDoc.exists) {
        transaction.delete(userFavoriteRef);
        final currentCount = mainItemDoc.data()?['favoriteCount'] ?? 0;
        if (currentCount > 0) {
          transaction
              .update(mainItemRef, {'favoriteCount': FieldValue.increment(-1)});
        }
      } else {
        transaction.set(userFavoriteRef, itemData);
        transaction
            .update(mainItemRef, {'favoriteCount': FieldValue.increment(1)});
      }
    });
  }

  /// Stream untuk mendengarkan status favorit sebuah item secara real-time.
  Stream<bool> isFavoritedStream(String userId, String itemId) {
    return _usersCollection
        .doc(userId)
        .collection('favorites')
        .doc(itemId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  /// Stream untuk mendapatkan semua item favorit dari seorang pengguna.
  Stream<QuerySnapshot<Map<String, dynamic>>> getFavoritesStream(
      String userId) {
    return _usersCollection
        .doc(userId)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots();
  }

  /// Stream untuk mendapatkan semua komentar dari seorang pengguna.
  Stream<QuerySnapshot<Map<String, dynamic>>> getMyCommentsStream(
      String userId) {
    return _commentsCollection
        .where('authorId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // # FUNGSI BARU: Untuk menghapus dokumen komentar berdasarkan ID-nya.
  /// Menghapus sebuah komentar dari collection 'comments'.
  ///
  /// [commentId] adalah ID unik dari dokumen komentar yang akan dihapus.
  Future<void> deleteComment(String commentId) async {
    try {
      await _commentsCollection.doc(commentId).delete();
    } catch (e) {
      print('Error saat menghapus komentar: $e');
      // Anda bisa menambahkan penanganan error lain di sini jika perlu,
      // misalnya menampilkan pesan kepada pengguna.
    }
  }
}
