import 'package:flutter/material.dart';
import 'package:tugas_akhir_flutter/checkout_cash.dart';

class IndosatPage extends StatelessWidget {
  final List<Point> points = [
    Point('Rp5.000', 5000, 'assets/images/indosat.png'),
    Point('Rp10.000', 10000, 'assets/images/indosat.png'),
    Point('Rp15.000', 15000, 'assets/images/indosat.png'),
    Point('Rp20.000', 20000, 'assets/images/indosat.png'),
    Point('Rp25.000', 25000, 'assets/images/indosat.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 0),
            Text(
              'Voucher',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
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
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: points.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: ListTile(
              leading: Image.asset(points[index].imagePath),
              contentPadding: EdgeInsets.all(10.0),
              title: Text(
                points[index].title,
                style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  _navigateToCheckout(context, points[index]);
                },
                style: ElevatedButton.styleFrom(
                  primary: Color.fromRGBO(255, 213, 0, 1),
                ),
                child: Text(
                  'Redeem',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
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

  void _navigateToCheckout(BuildContext context, Point point) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutCashPage(
          itemName: point.title,
          itemPrice: point.point.toDouble(),
          itemImage: point.imagePath,
        ),
      ),
    );
  }
}

class Point {
  final String title;
  final int point;
  final String imagePath;

  Point(this.title, this.point, this.imagePath);
}
