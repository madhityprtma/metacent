// ignore_for_file: unused_field
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tugas_akhir_flutter/dana.dart';
import 'package:tugas_akhir_flutter/indosat.dart';
import 'package:tugas_akhir_flutter/telkomsel.dart';
import 'package:tugas_akhir_flutter/tri.dart';
import 'package:tugas_akhir_flutter/voucher.dart';
import 'dashboard.dart';
import 'shop.dart';
import 'maps.dart';
import 'profil.dart';

void main() {
  runApp(Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class NoteCardSliders extends StatelessWidget {
  final List<String> imageUrls = [
    'assets/images/info1.png',
    'assets/images/info2.png',
    'assets/images/info3.png',
    'assets/images/info4.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(top: 73),
        child: CarouselSlider(
          items: imageUrls.map((imageUrl) {
            return buildNoteCard(imageUrl);
          }).toList(),
          options: CarouselOptions(
            aspectRatio: 16 / 9,
            viewportFraction: 0.91,
            autoPlay: false,
            autoPlayInterval: Duration(seconds: 3),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            autoPlayCurve: Curves.easeInOut,
            height: 210,
          ),
        ),
      ),
    );
  }

  Widget buildNoteCard(String imageUrl) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late CameraController? _cameraController;
  double _fabSize = 80.0;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String? _name;
  File? _profileImage;
  bool _isCameraActive = false;
  int _checkpointFromDatabase = 0;

  @override
  void initState() {
    super.initState();
    _getUserData();
    _loadImageFromLocalFile();
    _getCheckpointFromDatabase();
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

  void _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name');
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => Center(
                child: AlertDialog(
                  title: const Center(
                    child: Text('Do you want to exit?'),
                  ),
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          SystemNavigator.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                        ),
                        child: const Text('Yes'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 175, 76, 76),
                        ),
                        child: const Text('No'),
                      ),
                    ],
                  ),
                ),
              ),
            ) ??
            false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 12.0),
              child: GestureDetector(
                child: CircleAvatar(
                  foregroundColor: Color.fromARGB(255, 255, 255, 255),
                  backgroundColor: const Color.fromRGBO(74, 172, 79, 1),
                  backgroundImage:
                      _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? Icon(
                          Icons.account_circle,
                          size: 40,
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Container(
              color: Colors.white,
            ),
            _buildBackground(
              margin: 25.0,
              borderRadiusValue: 10.0,
            ),
            _buildBackgroundWhite(
              margin: 125.0,
              borderRadiusValue: 10.0,
            ),
            _buildBackgroundInfo(
              margin: 465.0,
              borderRadiusValue: 10.0,
            ),
            _buildBackgroundSlider(
              margin: 250.0,
            ),
            Container(
              padding: const EdgeInsets.only(
                  top: 50.0, left: 16.0, right: 16.0, bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    _name != null && _name!.isNotEmpty ? _name! : 'Guest',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            // NoteCardSliders(),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          elevation: 20.0,
          shape: CircularNotchedRectangle(),
          child: SizedBox(
            height: 70.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _buildNavigationItem(
                    iconPath: 'assets/images/home.png',
                    label: 'Home',
                    iconSize: 24.0,
                    onPressed: () {},
                  ),
                ),
                Expanded(
                  child: _buildNavigationItem(
                    iconPath: 'assets/images/shop.png',
                    label: 'Shop',
                    iconSize: 24.0,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShopPage(),
                        ),
                      );
                    },
                  ),
                ),
                const Expanded(
                  child: SizedBox.shrink(),
                ),
                Expanded(
                  child: _buildNavigationItem(
                    iconPath: 'assets/images/location.png',
                    label: 'Location',
                    iconSize: 24.0,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapsPage(),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: _buildNavigationItem(
                    iconPath: 'assets/images/profil.png',
                    label: 'Profile',
                    iconSize: 24.0,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: _fabSize + 10.0,
              height: _fabSize + 10.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),
            ),
            Container(
              width: 70.0,
              height: 70.0,
              child: FloatingActionButton(
                onPressed: () => _scanBarcode(context),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Image.asset(
                  'assets/images/scan.png',
                  width: 60.0,
                  height: 60.0,
                ),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildNavigationItem({
    required String iconPath,
    required String label,
    required double iconSize,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconPath,
            width: iconSize,
            height: iconSize,
          ),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: const TextStyle(fontSize: 12.0),
          ),
        ],
      ),
    );
  }

  Future<void> _scanBarcode(BuildContext context) async {
    try {
      if (!_isCameraActive) {
        _isCameraActive = true;
        _cameraController = await _initializeCamera(CameraLensDirection.back);
      }

      await _cameraController?.startImageStream((CameraImage image) {});

      String barcode = await FlutterBarcodeScanner.scanBarcode(
        '#00FF00',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );

      await _cameraController?.stopImageStream();
      _isCameraActive = false;

      if (barcode != '-1') {
        String uid = await _getUserUid();
        _saveActivedByToDatabase(barcode, uid);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardApp(),
          ),
        );
      }
    } catch (e) {
      print("Error while scanning barcode: $e");
      _isCameraActive = false;
    }
  }

  Future<String> _getUserUid() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return user.uid;
    }

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception("Google Sign-In canceled or failed");
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      return userCredential.user!.uid;
    } catch (e) {
      throw Exception("Error during Google Sign-In: $e");
    }
  }

  Future<CameraController> _initializeCamera(
      CameraLensDirection lensDirection) async {
    final cameras = await availableCameras();

    final camera = cameras.firstWhere(
      (camera) => camera.lensDirection == lensDirection,
      orElse: () => cameras.first,
    );

    final controller = CameraController(camera, ResolutionPreset.high);

    await controller.initialize();

    return controller;
  }

  void _saveActivedByToDatabase(String barcode, String uid) {
    DatabaseReference _databaseRef =
        FirebaseDatabase.instance.reference().child('alat');

    _databaseRef
        .orderByChild('id_alat')
        .equalTo(barcode)
        .onValue
        .listen((event) {
      if (event.snapshot.value != null && event.snapshot.value is Map) {
        Map<String, dynamic>? data =
            event.snapshot.value as Map<String, dynamic>?;
        data?.forEach((key, value) {
          _databaseRef.child(key).update({'actived_by': uid});
        });
      }
    });
  }

  void _goToMapsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapsPage(),
      ),
    );
  }

  void _goToProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(),
      ),
    );
  }

  Future<void> _selectProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('profile_picture', _profileImage!.path);
    }
  }

  void _getCheckpointFromDatabase() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DatabaseReference databaseReference =
          FirebaseDatabase.instance.reference();
      DatabaseReference pointRef = databaseReference.child("point").child(uid);

      pointRef.onValue.listen((event) {
        Map<dynamic, dynamic>? data =
            event.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          setState(() {
            _checkpointFromDatabase = data['checkpoint'] as int? ?? 0;
          });
        }
      }, onError: (error) {
        print("Error while reading data from Firebase: $error");
      });
    } catch (e) {
      print("Error while getting checkpoint data: $e");
    }
  }

  Widget _buildBackground(
      {double margin = 0.0, double borderRadiusValue = 0.0, int count = 0}) {
    return SafeArea(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: margin,
            child: Container(
              width: 350,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(74, 172, 79, 1),
                    Color.fromRGBO(74, 172, 79, 1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(borderRadiusValue),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'MetaPoint',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    '$_checkpointFromDatabase',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundWhite({
    double margin = 0.0,
    double borderRadiusValue = 0.0,
  }) {
    return SafeArea(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: margin,
            child: Container(
              width: 350,
              height: 120,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(borderRadiusValue),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(height: 5),
                  Text(
                    "Redeem MetaPoint Featured", // Judul yang ingin Anda tambahkan
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DanaPage(),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                width: 60,
                                height: 45,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage('assets/images/dana.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              "DANA",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 3),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VoucherPage(),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image:
                                        AssetImage('assets/images/voucher.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              "Voucher",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TriPage(),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage('assets/images/tri.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              "3",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IndosatPage(),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image:
                                        AssetImage('assets/images/indosat.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              "Indosat",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TelkomselPage(),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/telkomsel.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              "Telkomsel",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: Column(
                  children: [
                    Text(
                      "Redeem your MetaPoint without hassle, let's find out how!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              ListTile(
                leading: Container(
                  width: 60,
                  height: 60, // Tambahkan margin kanan
                  child: Image.asset('assets/images/tutor1.png'),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Check Your Metapoint",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Please check your MetaPoint balance.",
                      style: TextStyle(
                        fontSize: 13, // Ubah ukuran font di sini
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              ListTile(
                leading: Image.asset(
                  'assets/images/tutor2.png',
                  width: 60,
                  height: 60,
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Choose Items To Redeem",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Choose your desired items.",
                      style: TextStyle(
                        fontSize: 13, // Ubah ukuran font di sini
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              ListTile(
                leading: Image.asset(
                  'assets/images/tutor3.png',
                  width: 60,
                  height: 60,
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Redeem Now!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Redeem now, claim rewards instantly.",
                      style: TextStyle(
                        fontSize: 13, // Ubah ukuran font di sini
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                      context); // Menutup bottom sheet saat tombol ditekan
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  "Got It!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Warna tulisan
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildNoteCard(String imageUrl) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildBackgroundSlider({
    double margin = 0.0,
  }) {
    List<String> imageUrls = [
      'assets/images/info1.png',
      'assets/images/info2.png',
      'assets/images/info3.png',
      'assets/images/info4.png',
    ];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(top: margin),
        child: CarouselSlider(
          items: imageUrls.map((imageUrl) {
            return buildNoteCard(imageUrl);
          }).toList(),
          options: CarouselOptions(
            aspectRatio: 16 / 9,
            viewportFraction: 0.91,
            autoPlay: false,
            autoPlayInterval: Duration(seconds: 3),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            autoPlayCurve: Curves.easeInOut,
            height: 210,
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundInfo({
    double margin = 0.0,
    double borderRadiusValue = 0.0,
  }) {
    return SafeArea(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: margin,
            child: Container(
              width: 349,
              height: 185,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(74, 172, 79, 1),
                    Color.fromRGBO(74, 172, 79, 1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(borderRadiusValue),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Image.asset(
                  'assets/images/info5.png',
                  width: 350,
                  height: 185,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
