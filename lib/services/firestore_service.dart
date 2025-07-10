// File: lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Mendapatkan referensi ke semua collection yang kita gunakan
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _koleksiCollection =>
      _db.collection('koleksi');
  CollectionReference<Map<String, dynamic>> get _commentsCollection =>
      _db.collection('comments');
  CollectionReference<Map<String, dynamic>> get _quizzesCollection =>
      _db.collection('quiz');
  CollectionReference<Map<String, dynamic>> get _leaderboardCollection =>
      _db.collection('leaderboard');

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

  Future<void> updateUserData(User user) async {
    final docRef = _usersCollection.doc(user.uid);

    return docRef.set(
        {
          'userId': user.uid,
          'userName': user.displayName,
          'email': user.email,
        },
        SetOptions(
            merge:
                true)); // SetOptions(merge: true) akan membuat dokumen baru jika belum ada,
    // atau memperbarui yang sudah ada tanpa menghapus data lama (seperti sub-collection 'favorites').
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

  /// Menghapus sebuah komentar dari collection 'comments'.
  Future<void> deleteComment(String commentId) async {
    try {
      await _commentsCollection.doc(commentId).delete();
    } catch (e) {
      print('Error saat menghapus komentar: $e');
    }
  }

  Future<List<DocumentSnapshot>> getAllQuizzes() async {
    try {
      final querySnapshot = await _quizzesCollection.get();
      return querySnapshot.docs;
    } catch (e) {
      print('Error mengambil semua kuis: $e');
      return [];
    }
  }

  Future<bool> canPlayQuiz(String userId) async {
    try {
      final docRef = _leaderboardCollection.doc(userId);
      final doc = await docRef.get();

      if (!doc.exists) {
        return true;
      }

      final data = doc.data() as Map<String, dynamic>;
      final attempts = data['quizAttempts'] as int? ?? 0;

      return attempts < 3;
    } catch (e) {
      print('Error memeriksa kesempatan kuis: $e');
      return false;
    }
  }

  /// Memperbarui skor dan jumlah percobaan kuis pengguna di leaderboard.
  Future<void> updateUserScore(User user, int newScore) async {
    final docRef = _leaderboardCollection.doc(user.uid);

    return _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        // Jika pengguna belum ada di leaderboard, buat data baru.
        transaction.set(docRef, {
          // # PERUBAHAN: Menambahkan userId, userName, dan email
          'userId': user.uid,
          'userName': user.displayName ?? 'Pengguna Anonim',
          'email': user.email ?? 'Tidak ada email',
          // 'userPhotoUrl':
          //     user.photoURL ?? '', // Kita simpan juga URL foto untuk efisiensi
          'score': newScore,
          'quizAttempts': 1,
          'lastPlayed': FieldValue.serverTimestamp(),
        });
      } else {
        // Jika pengguna sudah ada, perbarui datanya.
        final currentData = snapshot.data() as Map<String, dynamic>;
        final currentScore = currentData['score'] as int? ?? 0;

        // Hanya update skor jika skor baru lebih tinggi
        if (newScore > currentScore) {
          transaction.update(docRef, {'score': newScore});
        }

        // Selalu update jumlah percobaan dan data pengguna lainnya
        transaction.update(docRef, {
          'quizAttempts': FieldValue.increment(1),
          'lastPlayed': FieldValue.serverTimestamp(),
          'userName': user.displayName ?? 'Pengguna Anonim',
          'email': user.email ?? 'Tidak ada email',
          'userPhotoUrl': user.photoURL ?? '',
        });
      }
    });
  }

  Future<int> getQuizAttempts(String userId) async {
    try {
      final docRef = _leaderboardCollection.doc(userId);
      final doc = await docRef.get();

      if (!doc.exists) {
        return 0;
      }

      final data = doc.data() as Map<String, dynamic>;
      return data['quizAttempts'] as int? ?? 0;
    } catch (e) {
      print('Error mendapatkan percobaan kuis: $e');
      return 0;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getLeaderboardStream() {
    return _leaderboardCollection
        .orderBy('score', descending: true)
        .orderBy('lastPlayed', descending: true)
        .snapshots();
  }
}
