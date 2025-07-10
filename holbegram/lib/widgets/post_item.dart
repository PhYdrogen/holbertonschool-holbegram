import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:holbegram/methods/favorite_methods.dart';
import 'package:holbegram/screens/pages/methods/post_storage.dart';
import 'package:holbegram/providers/user_provider.dart';
import 'package:provider/provider.dart';

class PostItem extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostItem({Key? key, required this.post}) : super(key: key);

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  bool _isFavorited = false;
  late FavoriteMethods _favoriteMethods;
  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    _favoriteMethods = FavoriteMethods();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _currentUserId =
          Provider.of<UserProvider>(context, listen: false).getUser.uid;
      _checkFavoriteStatus();
    });
  }

  void _checkFavoriteStatus() async {
    bool favorited = await _favoriteMethods.isFavorited(
        widget.post['postId'], _currentUserId);
    setState(() {
      _isFavorited = favorited;
    });
  }

  void _toggleFavorite() async {
    await _favoriteMethods.toggleFavorite(
        widget.post['postId'], _currentUserId);
    setState(() {
      _isFavorited = !_isFavorited;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(widget.post['profImage']),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      widget.post['username'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () async {
                    PostStorage postStorage = PostStorage();
                    await postStorage.deletePost(
                        widget.post['postId'], widget.post['publicId']);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Post Deleted'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                widget.post['caption'],
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.post['postUrl']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // Implement like functionality
                },
              ),
              IconButton(
                icon: const Icon(Icons.comment),
                onPressed: () {
                  // Implement comment functionality
                },
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  // Implement send functionality
                },
              ),
              IconButton(
                icon: Icon(
                  _isFavorited ? Icons.bookmark : Icons.bookmark_border,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
