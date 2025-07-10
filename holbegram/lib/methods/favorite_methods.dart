import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> toggleFavorite(String postId, String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      List<dynamic> favorites = userDoc['favorites'] ?? [];

      if (favorites.contains(postId)) {
        // Post is already favorited, remove it
        await _firestore.collection('users').doc(uid).update({
          'favorites': FieldValue.arrayRemove([postId]),
        });
      } else {
        // Post is not favorited, add it
        await _firestore.collection('users').doc(uid).update({
          'favorites': FieldValue.arrayUnion([postId]),
        });
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  Future<bool> isFavorited(String postId, String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      List<dynamic> favorites = userDoc['favorites'] ?? [];
      return favorites.contains(postId);
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }
}
