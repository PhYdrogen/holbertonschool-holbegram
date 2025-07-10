import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:holbegram/methods/auth_methods.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import 'package:holbegram/providers/user_provider.dart';
import 'package:holbegram/screens/pages/methods/post_storage.dart';
import 'package:holbegram/screens/home.dart';

class AddImage extends StatefulWidget {
  const AddImage({super.key});

  @override
  State<AddImage> createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  Uint8List? _image;
  final TextEditingController _captionController = TextEditingController();
  bool _isLoading = false;
  DocumentSnapshot? user;

  @override
  void initState() {
    super.initState();
    userInfo();
  }

  @override
  void dispose() {
    super.dispose();
    _captionController.dispose();
  }

  Future<void> userInfo() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore ff = FirebaseFirestore.instance;
    var u = await ff.collection('users').doc(auth.currentUser?.uid).get();
    setState(()  {
      user = u;
    });
  }

  void selectImage() async {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Create a Post'),
          children: [
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List? file = await pickImage(ImageSource.camera);
                setState(() {
                  _image = file;
                });
              },
              child: const Text('Take a photo'),
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List? file = await pickImage(ImageSource.gallery);
                setState(() {
                  _image = file;
                });
              },
              child: const Text('Choose from gallery'),
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<Uint8List?> pickImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();
    XFile? _file = await _imagePicker.pickImage(source: source);
    if (_file != null) {
      return await _file.readAsBytes();
    }
    print('No image selected');
    return null;
  }

  void postImage(
    String uid,
    String username,
    String profImage,
  ) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String res = await PostStorage().uploadPost(
        _captionController.text,
        uid,
        username,
        profImage,
        _image!,
      );

      if (res == 'Ok') {
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) {
          showSnackBar('Posted!', context);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const Home(),
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) {
          showSnackBar(res, context);
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        showSnackBar(e.toString(), context);
      }
    }
  }

  void showSnackBar(String content, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Add Image'),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () => postImage(
              user?["uid"],
              user?["username"],
              user?["photoUrl"],
            ),
            child: const Text(
              'Post',
              style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  fontFamily: 'Billabong'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _isLoading
              ? const LinearProgressIndicator()
              : const Padding(padding: EdgeInsets.only(top: 0)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Choose an image from your gallery or take a one.',
              style: TextStyle(fontSize: 16),
            ),
          ),
          TextField(
            controller: _captionController,
            decoration: InputDecoration(
              hintText: 'Write a caption...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          GestureDetector(
            onTap: selectImage,
            child: Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: _image != null
                  ? Image.memory(_image!, fit: BoxFit.cover)
                  : Icon(
                      Icons.image,
                      size: 100,
                      color: Colors.grey[600],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
