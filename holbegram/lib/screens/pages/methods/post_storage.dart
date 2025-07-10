import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:holbegram/models/post.dart';
import 'package:holbegram/screens/auth/methods/user_storage.dart';

class PostStorage {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(String caption, String uid, String username,
      String profImage, Uint8List image) async {
    String res = "Some error occurred";
    try {
      String postId = const Uuid().v1();
      Map<String, String> photoInfo =
          await StorageMethods().uploadImageToCloudinary(image, 'posts');
      String photoUrl = photoInfo['url']!;
      String publicId = photoInfo['publicId']!;

      Post post = Post(
        caption: caption,
        uid: uid,
        username: username,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage,
        likes: [],
        publicId: publicId,
      );

      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "Ok";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> deletePost(String postId, String publicId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
      await StorageMethods().deleteImageFromCloudinary(publicId);
    } catch (e) {
      print(e.toString());
    }
  }
}
