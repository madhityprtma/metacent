import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'checkout.dart';
import 'dashboard.dart';
import 'maps.dart';
import 'profil.dart';
import 'utama.dart';

class ShopPage extends StatefulWidget {
  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final _searchController = TextEditingController();
  final double _fabSize = 80.0;
  bool _isCameraActive = false;
  late CameraController? _cameraController;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 0),
            Text(
              'MetaShop',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                _showBottomSheet(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: 30,
                  height: 30,
                  child: Icon(
                    Icons.help_outline,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          const SizedBox(height: 16.0),
          Expanded(child: _buildProductList()),
          const SizedBox(height: 20),
        ],
      ),
      floatingActionButton: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: _fabSize + 10.0,
            height: _fabSize + 10.0,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromRGBO(74, 172, 79, 1),
            ),
          ),
          SizedBox(
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: _buildNavigationItem(
                  iconPath: 'assets/images/shop.png',
                  label: 'Shop',
                  iconSize: 24.0,
                  onPressed: () {},
                ),
              ),
              Expanded(
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
    );
  }

  Widget _buildProductList() {
    List<Product> products = [
      Product(
        name: 'Organize Bag',
        price: 5000,
        description: '',
        image: 'assets/images/product1.png',
      ),
      Product(
        name: 'Cutlery',
        price: 1000,
        description: '',
        image: 'assets/images/product2.png',
      ),
      Product(
        name: 'Tote Bag',
        price: 3000,
        description: '',
        image: 'assets/images/product3.png',
      ),
      Product(
        name: 'Mini Tumblr',
        price: 2000,
        description: '',
        image: 'assets/images/product4.png',
      ),
      Product(
        name: 'Hand Bag',
        price: 3000,
        description: '',
        image: 'assets/images/product5.png',
      ),
    ];

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductItem(products[index]);
      },
    );
  }

  Widget _buildProductItem(Product product) {
    return GestureDetector(
      onTap: () {
        _openCheckoutPage(product);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          double containerHeight = constraints.maxHeight;

          return Container(
            height: containerHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                  child: Image.asset(
                    product.image,
                    width: double.infinity,
                    height: containerHeight - 60.0,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/metapoint.png',
                            width: 18.0,
                            height: 18.0,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              product.price.toStringAsFixed(0),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color.fromRGBO(74, 172, 79, 1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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

        _showScanResultToast(barcode, uid);

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

  void _showScanResultToast(String barcode, String uid) {
    Fluttertoast.showToast(
      msg: "Barcode: $barcode\nUID Pengguna: $uid",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
    );
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

  void _openCheckoutPage(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          itemName: product.name,
          itemPrice: product.price,
          itemImage: product.image,
        ),
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
}

class Product {
  final String name;
  final double price;
  final String description;
  final String image;

  Product({
    required this.name,
    required this.price,
    required this.description,
    required this.image,
  });
}
