import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Mendapatkan referensi ke semua collection yang digunakan
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
  CollectionReference<Map<String, dynamic>> get _badgesCollection =>
      _db.collection('badges');

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

  Future<void> updateComment(String commentId, String newText) async {
    try {
      await _commentsCollection.doc(commentId).update({
        'text': newText,
        'isEdited': true, // Menandai bahwa komentar ini pernah diedit
        'editedAt': FieldValue.serverTimestamp(), // Menyimpan waktu edit
      });
    } catch (e) {
      print('Error saat mengedit komentar: $e');
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
          'userId': user.uid,
          'userName': user.displayName ?? 'Pengguna Anonim',
          'email': user.email ?? 'Tidak ada email',
          'userPhotoUrl': user.photoURL ?? '',
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

  // --- FUNGSI BARU UNTUK FITUR LENCANA (BADGES) ---

  /// Fungsi utama untuk memberikan lencana jika syarat terpenuhi.
  Future<DocumentSnapshot?> _checkAndAwardBadge(
      String userId, String badgeId) async {
    final userBadgesRef =
        _usersCollection.doc(userId).collection('earnedBadges').doc(badgeId);
    final doc = await userBadgesRef.get();

    if (!doc.exists) {
      final badgeInfo = await _badgesCollection.doc(badgeId).get();
      if (badgeInfo.exists) {
        await userBadgesRef.set({
          'name': badgeInfo.data()?['name'],
          'description': badgeInfo.data()?['description'],
          'iconName': badgeInfo.data()?['iconName'],
          'iconColor': badgeInfo.data()?['iconColor'],
          'earnedAt': FieldValue.serverTimestamp(),
        });
        return badgeInfo;
      }
    }
    return null;
  }

  /// Melacak setiap kali pengguna melihat halaman detail koleksi.
  Future<DocumentSnapshot?> trackDetailView(
      String userId, String itemId) async {
    final userRef = _usersCollection.doc(userId);
    await userRef.set({
      'viewedItems': FieldValue.arrayUnion([itemId])
    }, SetOptions(merge: true));

    final userData = await userRef.get();
    final viewedItems =
        List<String>.from(userData.data()?['viewedItems'] ?? []);
    if (viewedItems.length >= 10) {
      return await _checkAndAwardBadge(userId, 'penjelajah_museum');
    }
    return null;
  }

  Future<DocumentSnapshot?> trackGalleryImageView(String userId) async {
    final userRef = _usersCollection.doc(userId);
    await userRef.set({'galleryImageViews': FieldValue.increment(1)},
        SetOptions(merge: true));

    final userData = await userRef.get();
    if ((userData.data()?['galleryImageViews'] ?? 0) >= 20) {
      return await _checkAndAwardBadge(userId, 'pecinta_galeri');
    }
    return null;
  }

  /// Melacak setiap kali pengguna memindai QR Code.
  Future<DocumentSnapshot?> trackQrScan(String userId, String itemId) async {
    final userRef = _usersCollection.doc(userId);
    await userRef.set({
      'scannedItems': FieldValue.arrayUnion([itemId])
    }, SetOptions(merge: true));

    final userData = await userRef.get();
    final scannedItems =
        List<String>.from(userData.data()?['scannedItems'] ?? []);
    if (scannedItems.length >= 8) {
      return await _checkAndAwardBadge(userId, 'si_detektif');
    }
    return null;
  }

  /// Melacak setiap kali pengguna membuka halaman kategori.
  Future<DocumentSnapshot?> trackCategoryView(
      String userId, String categoryName) async {
    final userRef = _usersCollection.doc(userId);
    await userRef.set({
      'categoriesOpened': FieldValue.arrayUnion([categoryName])
    }, SetOptions(merge: true));

    final userData = await userRef.get();
    final categories =
        List<String>.from(userData.data()?['categoriesOpened'] ?? []);
    if (categories
        .toSet()
        .containsAll(['Artefak', 'Batuan', 'Fosil', 'Mineral'])) {
      return await _checkAndAwardBadge(userId, 'tur_virtual_lengkap');
    }
    return null;
  }

  /// Melacak saat pengguna memfavoritkan item.
  Future<DocumentSnapshot?> trackFavoriteAction(String userId) async {
    final userRef = _usersCollection.doc(userId);
    final favoritesSnapshot =
        await userRef.collection('favorites').count().get();
    final favoritesCount = favoritesSnapshot.count ?? 0;

    await userRef
        .set({'favoritedItemsCount': favoritesCount}, SetOptions(merge: true));

    if (favoritesCount >= 10) {
      return await _checkAndAwardBadge(userId, 'pecinta_koleksi');
    }
    return null;
  }

  /// Melacak setiap kali pengguna mengirim komentar.
  Future<DocumentSnapshot?> trackCommentPost(
      String userId, String itemId) async {
    final userRef = _usersCollection.doc(userId);
    await userRef.set({
      'commentedOnItems': FieldValue.arrayUnion([itemId])
    }, SetOptions(merge: true));

    final userData = await userRef.get();
    final commentedItems =
        List<String>.from(userData.data()?['commentedOnItems'] ?? []);
    if (commentedItems.length >= 5) {
      return await _checkAndAwardBadge(userId, 'pemberi_suara');
    }
    return null;
  }

  /// Melacak apakah pengguna menjadi "Pengunjung Aktif".
  Future<DocumentSnapshot?> trackActiveVisitor(
      String userId, String itemId) async {
    final favoriteDoc = await _usersCollection
        .doc(userId)
        .collection('favorites')
        .doc(itemId)
        .get();
    final commentQuery = await _commentsCollection
        .where('itemId', isEqualTo: itemId)
        .where('authorId', isEqualTo: userId)
        .limit(1)
        .get();

    if (favoriteDoc.exists && commentQuery.docs.isNotEmpty) {
      return await _checkAndAwardBadge(userId, 'pengunjung_aktif');
    }
    return null;
  }

  /// Melacak skor kuis untuk lencana "Ahli Sejarah".
  Future<DocumentSnapshot?> trackQuizScore(String userId, int score) async {
    if (score >= 90) {
      return await _checkAndAwardBadge(userId, 'ahli_sejarah');
    }
    return null;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllBadgesStream() {
    return _badgesCollection.snapshots();
  }

  /// Stream untuk mendapatkan semua lencana yang telah dimiliki pengguna.
  Stream<QuerySnapshot<Map<String, dynamic>>> getEarnedBadgesStream(
      String userId) {
    return _usersCollection
        .doc(userId)
        .collection('earnedBadges')
        .orderBy('earnedAt', descending: true)
        .snapshots();
  }
}
