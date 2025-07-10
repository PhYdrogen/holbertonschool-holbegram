import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:holbegram/methods/auth_methods.dart';

void showSnackBar(String content, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

class AddPicture extends StatefulWidget {
  final String email;
  final String password;
  final String username;

  const AddPicture({
    Key? key,
    required this.email,
    required this.password,
    required this.username,
  }) : super(key: key);

  @override
  State<AddPicture> createState() => _AddPictureState();
}

class _AddPictureState extends State<AddPicture> {
  Uint8List? _image;

  void selectImageFromGallery() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  void selectImageFromCamera() async {
    Uint8List im = await pickImage(ImageSource.camera);
    setState(() {
      _image = im;
    });
  }

  // Helper function to pick image (assuming it's defined elsewhere or will be added)
  Future<Uint8List> pickImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();
    XFile? _file = await _imagePicker.pickImage(source: source);
    if (_file != null) {
      return await _file.readAsBytes();
    }
    print('No image selected');
    return Uint8List(0); // Return an empty Uint8List if no image is selected
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 28),
            Text(
              'Holbegram',
              style: TextStyle(
                fontFamily: 'Billabong',
                fontSize: 50,
              ),
            ),
            Image.asset(
              'assets/images/logo.webp',
              width: 80,
              height: 60,
            ),
            SizedBox(height: 20),
            Text(
              "Hello, ${widget.username} Welcome to Holbegram.",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            Text(
              "Choose an image from your gallery or take a new one.",
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            SizedBox(height: 20),
            Stack(
              children: [
                _image != null
                    ? CircleAvatar(
                        radius: 64,
                        backgroundImage: MemoryImage(_image!),
                      )
                    : const CircleAvatar(
                        radius: 64,
                        backgroundImage: NetworkImage(
                            'https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png'),
                      ),
                Positioned(
                  bottom: -10,
                  left: 80,
                  child: IconButton(
                    onPressed: selectImageFromCamera,
                    icon: const Icon(Icons.add_a_photo),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: selectImageFromCamera,
                ),
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: selectImageFromGallery,
                ),
              ],
            ),
            TextButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                backgroundColor: WidgetStateProperty.all(
                  Color.fromARGB(218, 226, 37, 24),
                ),
              ),
              onPressed: () async {
                String res = await AuthMethode().signUpUser(
                  email: widget.email,
                  password: widget.password,
                  username: widget.username,
                  file: _image,
                );
                if (res == 'success') {
                  showSnackBar('Sign up successful!', context);
                } else {
                  showSnackBar(res, context);
                }
              },
              child: const Text(
                'Next',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
