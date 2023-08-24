// ignore_for_file: unused_field, unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import 'daftar_masuk.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  String _name = "";
  String _phoneNumber = "";
  final _picker = ImagePicker();
  final _nameController =
      TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadImageFromLocalFile();
  }

  @override
  void dispose() {
    _nameController
        .dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? "";
      _phoneNumber = prefs.getString('phoneNumber') ?? "";
      _nameController.text =
          _name;
      _phoneNumberController.text = _phoneNumber;
    });
  }

  Future<void> _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'name', _nameController.text);
    await prefs.setString('phoneNumber', _phoneNumberController.text);
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

  void _navigateToHomepage() {
    _saveUserData();
    Navigator.pop(context);
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text("Log Out")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Are you sure you want to log out?"),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _logout();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromRGBO(74, 172, 79, 1),
                    ),
                    child: Text('Yes'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 175, 76, 76),
                    ),
                    child: Text('No'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color iconBackgroundColor = const Color.fromRGBO(74, 172, 79, 1);

    return WillPopScope(
      onWillPop: () async {
        _navigateToHomepage();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            onTap: () {
              _navigateToHomepage();
            },
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
          title: Row(
            mainAxisAlignment:
                MainAxisAlignment.start,
            children: [
              const SizedBox(width: 0),
              Text(
                'Profile',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: ImageIcon(
                AssetImage(
                    'assets/images/log_out.png'),
                color: Colors.black,
              ),
              onPressed: () {
                _showLogoutConfirmationDialog();
              },
            ),
          ],
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: _getImageFromGallery,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: const Color.fromRGBO(74, 172, 79, 1),
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? Icon(
                            Icons.camera_alt,
                            size: 60,
                            color: Colors.white.withOpacity(0.7),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    setState(() {
                      _name = 'new_username';
                    });
                    _saveUserData();
                  },
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
                InkWell(
                  onTap: () {
                    setState(() {
                      _phoneNumber = 'new_phone_number';
                    });
                    _saveUserData();
                  },
                  child: TextFormField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    keyboardType: TextInputType
                        .phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    readOnly: false,
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 209),
                const Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Contact Us'),
                      Text('Email: mapratama317@gmail.com'),
                      Text('Phone: 08973023504'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('App Info'),
                      Text('Version: Beta'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Image.asset(
                    'assets/images/marker.png',
                    width: 40,
                    height: 40,
                  ),
                ),
                const Text('Metacent'),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
