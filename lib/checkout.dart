import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class CheckoutPage extends StatefulWidget {
  final String itemName;
  final double itemPrice;
  final String itemImage;

  const CheckoutPage({
    required this.itemName,
    required this.itemPrice,
    required this.itemImage,
  });

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late User _user;
  late DatabaseReference _databaseRef;
  double _userCheckpoint = 0;
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _databaseRef = FirebaseDatabase.instance.reference().child('point');
    _loadUserCheckpoint();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
  }

  void _loadUserCheckpoint() async {
    DataSnapshot snapshot = await _databaseRef.child(_user.uid).get();
    Map<dynamic, dynamic>? userData = snapshot.value as Map<dynamic, dynamic>?;
    if (userData != null && userData.containsKey('checkpoint')) {
      setState(() {
        _userCheckpoint = userData['checkpoint'].toDouble();
      });
    }
  }

  void _showInsufficientPointsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: AlertDialog(
          title: const Center(
            child: Text('Insufficient Metapoints'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('You do not have enough Metapoints to purchase this item'),
              SizedBox(height: 20), // Sesuaikan jarak antara teks dan tombol
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromRGBO(74, 172, 79, 1),
                ),
                child: Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotCompletedText(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: AlertDialog(
          title: const Center(
            child: Text('Data Verification Required'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Please ensure your profile information is verified',
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromRGBO(74, 172, 79, 1),
                ),
                child: Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Checkout',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16),
            Center(
              child: Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage(widget.itemImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.itemName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/metapoint.png',
                              width: 18,
                              height: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${widget.itemPrice.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 18,
                                color: const Color.fromRGBO(74, 172, 79, 1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Your MetaPoint : ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_userCheckpoint.toInt()}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color.fromRGBO(74, 172, 79, 1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: Text(
                      'Data Verification',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Name:'),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Address:'),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Phone Number:'),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () async {
            if (_userCheckpoint >= widget.itemPrice) {
              String name = _nameController.text;
              String address = _addressController.text;
              String phone = _phoneController.text;
              if (name == "" || address == "" || phone == "")
                _showNotCompletedText(context);
              else {
                bool paymentSuccess = await _performPayment(widget.itemPrice);
                if (paymentSuccess) {
                  _updateUserPoint(widget.itemPrice);

                  _openWhatsApp(name, address, phone);
                } else {
                  _showPaymentErrorDialog(context);
                }
              }
            } else {
              _showInsufficientPointsDialog(context);
            }
          },
          style: ElevatedButton.styleFrom(
            primary: const Color.fromRGBO(74, 172, 79, 1),
            padding: EdgeInsets.symmetric(
              horizontal: 40.0,
              vertical: 16.0,
            ),
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: Text('Proceed to Payment'),
        ),
      ),
    );
  }

  Future<bool> _performPayment(double amount) async {
    // Implement payment process here
    // For demonstration, assuming payment is successful
    bool paymentSuccess = true; // Assuming payment is successful

    if (paymentSuccess) {
      _showPaymentSuccessDialog(context);
    }

    return paymentSuccess;
  }

  void _showPaymentSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.all(20.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 64,
              ),
              SizedBox(height: 20),
              Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup pop-up sukses
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateUserPoint(double deductionAmount) {
    double updatedCheckpoint = _userCheckpoint - deductionAmount;
    _databaseRef.child(_user.uid).update({'checkpoint': updatedCheckpoint});
    setState(() {
      _userCheckpoint = updatedCheckpoint;
    });
  }

  void _showPaymentErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: AlertDialog(
          title: const Center(
            child: Text('Payment Error'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('An error occurred while processing your payment.'),
              SizedBox(height: 12), // Sesuaikan jarak antara teks dan tombol
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                ),
                child: Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openWhatsApp(String name, String address, String phone) async {
    final phoneNumber = '628973023504';

    final itemName = Uri.encodeComponent(widget.itemName);
    final itemPrice = widget.itemPrice.toStringAsFixed(0);
    final nameEncoded = Uri.encodeComponent(name);
    final addressEncoded = Uri.encodeComponent(address);
    final phoneEncoded = Uri.encodeComponent(phone);

    final message =
        'Hello! I would like to verify my payment for my order.%0A%0A'
        'Order Details:%0AItem: $itemName%0APrice: $itemPrice%0A%0A'
        'Verification Data:%0AName: $nameEncoded%0AAddress: $addressEncoded%0APhone Number: $phoneEncoded';

    final whatsappUrl = "whatsapp://send?phone=$phoneNumber&text=$message";

    try {
      await launch(whatsappUrl);
    } on Exception catch (e) {
      throw 'Could not launch WhatsApp: $e';
    }
  }
}
