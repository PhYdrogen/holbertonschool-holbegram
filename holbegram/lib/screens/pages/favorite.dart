import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:holbegram/providers/user_provider.dart';
import 'package:holbegram/widgets/post_item.dart';
import 'package:provider/provider.dart';

class Favorite extends StatefulWidget {
  const Favorite({Key? key}) : super(key: key);

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final String currentUserId = userProvider.getUser.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: false,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User data not found.'));
          }

          List<dynamic> favoritePostIds = snapshot.data!['favorites'] ?? [];

          if (favoritePostIds.isEmpty) {
            return const Center(child: Text('No favorite posts yet.'));
          }

          return ListView.builder(
            itemCount: favoritePostIds.length,
            itemBuilder: (context, index) {
              String postId = favoritePostIds[index];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postId)
                    .get(),
                builder: (context, postSnapshot) {
                  if (postSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (postSnapshot.hasError) {
                    return Center(child: Text('Error: ${postSnapshot.error}'));
                  }
                  if (!postSnapshot.hasData || !postSnapshot.data!.exists) {
                    return const SizedBox
                        .shrink(); // Post might have been deleted
                  }
                  final postData =
                      postSnapshot.data!.data() as Map<String, dynamic>;
                  return PostItem(post: postData);
                },
              );
            },
          );
        },
      ),
    );
  }
}
