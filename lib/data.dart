import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'utama.dart'; // Ganti dengan import halaman HomePage yang sesuai

class DataPage extends StatefulWidget {
  const DataPage({Key? key}) : super(key: key);

  @override
  _DataPageState createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  File? _profileImage;
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadImageFromLocalFile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _getImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      _saveImageToLocalFile(_profileImage!);
    }
  }

  Future<void> _saveImageToLocalFile(File image) async {
    final appDir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'profile_picture_$timestamp.png';
    final localImagePath = '${appDir.path}/$fileName';

    if (await File(localImagePath).exists()) {
      await File(localImagePath).delete();
    }

    await image.copy(localImagePath);
    setState(() {
      _profileImage = File(localImagePath);
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('imageTimestamp', timestamp);
  }

  Future<void> _loadImageFromLocalFile() async {
    final appDir = await getApplicationDocumentsDirectory();
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('imageTimestamp') ?? 0;
    final fileName = 'profile_picture_$timestamp.png';
    final localImagePath = '${appDir.path}/$fileName';

    if (await File(localImagePath).exists()) {
      setState(() {
        _profileImage = File(localImagePath);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Profile Info",
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Please provide your username, phone number, and profile photo",
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 25),
            InkWell(
              onTap: _getImageFromGallery,
              child: CircleAvatar(
                radius: 80,
                backgroundColor: const Color.fromRGBO(74, 172, 79, 1),
                backgroundImage:
                    _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? Icon(
                        Icons.camera_alt,
                        size: 60,
                        color: Colors.white.withOpacity(0.7),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 16), // Add horizontal padding
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                readOnly: false,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 16), // Add horizontal padding
              child: TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                keyboardType:
                    TextInputType.phone, // Hanya angka yang muncul di keyboard
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ], // Hanya menerima input digit (angka)
                readOnly: false,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isEmpty ||
                    _phoneNumberController.text.isEmpty) {
                  Fluttertoast.showToast(
                    msg: 'Please fill in all fields and select a profile photo',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                } else {
                  _saveImageToLocalFile(_profileImage!);
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setString('name', _nameController.text);
                  await prefs.setString(
                      'phoneNumber', _phoneNumberController.text);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HomePage()), // Ganti dengan halaman HomePage yang sesuai
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Color.fromRGBO(74, 173, 78, 1), // Warna hijau
              ),
              child: Text('Save'),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
