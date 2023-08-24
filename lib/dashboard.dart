import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tugas_akhir_flutter/utama.dart';

void main() {
  runApp(const DashboardApp());
}

class DashboardApp extends StatelessWidget {
  const DashboardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final String id_alat = "626771718";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int logam = 0;
  int nonLogam = 0;
  int totalPoint = 0;
  int grandTotal = 0;

  @override
  void initState() {
    super.initState();
    widget._auth.authStateChanges().listen((User? user) {
      if (user != null) {
        print("User signed in with UID: ${user.uid}");
        saveActivedByToDatabase(widget.id_alat, user.uid);
        savePoint(user.uid);
      } else {
        print("User is signed out");
      }
    });
  }

  Future<void> _handleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser =
          await widget._googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await widget._auth.signInWithCredential(credential);
      print("User signed in with UID: ${userCredential.user?.uid}");
      // saveActivedByToDatabase(id_alat, userCredential.user!.uid);
    } catch (e) {
      print("Error: $e");
    }
  }

  void saveActivedByToDatabase(String id_alat, String uid) async {
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference
        .child('alat')
        .child(id_alat)
        .update({'actived_by': uid});
  }

  void savePoint(String uid) {
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
    DatabaseReference pointRef = databaseReference.child("point").child(uid);

    pointRef.onValue.listen((event) {
      Map<dynamic, dynamic>? data =
          event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) {
        pointRef.set({
          'logam': 0,
          'non_logam': 0,
          'checkpoint': 0,
        });
      } else {
        int existingLogam = data['logam'] as int? ?? 0;
        int existingNonLogam = data['non_logam'] as int? ?? 0;
        int existingCheckpoint = data['checkpoint'] as int? ?? 0;

        setState(() {
          logam = existingLogam;
          nonLogam = existingNonLogam;
          grandTotal = existingCheckpoint;
          totalPoint = logam + nonLogam;
        });
      }
    }, onError: (error) {
      print("Error while reading data from Firebase: $error");
    });
  }

  void updateTotalPoint(int totalPoint, int grandTotal) async {
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference
        .child("point")
        .child(widget._auth.currentUser!.uid)
        .update({
      'checkpoint': grandTotal,
    });

    setState(() {
      this.totalPoint = totalPoint;
      this.grandTotal = grandTotal;
    });
  }

  void updateCircularProgressWidgets(int logamCount, int nonLogamCount) {
    setState(() {
      logam = logamCount;
      nonLogam = nonLogamCount;
      totalPoint = logam + nonLogam;
    });
  }

  void _handleSelesaiButton() async {
    int newLogam = 0;
    int newNonLogam = 0;
    int newTotalPoint = 0;

    int newGrandTotal = grandTotal + totalPoint;

    updateTotalPoint(newTotalPoint, newGrandTotal);
    updateCircularProgressWidgets(newLogam, newNonLogam);

    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference
        .child("point")
        .child(widget._auth.currentUser!.uid)
        .update({
      'logam': newLogam,
      'non_logam': newNonLogam,
    });

    saveActivedByToDatabase(widget.id_alat, "");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(''),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 70),
            Text(
              'Metacent Sorting System',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            NoteCardSliders(),
            const SizedBox(height: 70),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircularProgessWidget(
                        label: 'Metal',
                        count: logam,
                        maxValue: 500,
                      ),
                      SizedBox(width: 20),
                      CircularProgessWidget(
                        label: 'Non Metal',
                        count: nonLogam,
                        maxValue: 100,
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Text(
                    'MetaPoint : $totalPoint',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 80),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _handleSelesaiButton,
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 76, 175, 80),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                      ),
                      child: const Text(
                        'Finish',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularProgessWidget extends StatelessWidget {
  final String label;
  final int count;
  final int maxValue;

  const CircularProgessWidget({
    Key? key,
    required this.label,
    required this.count,
    required this.maxValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double radius = 80;
    double strokeWidth = 10;
    double progressValue = count / maxValue;
    double fontSize = 20;

    return Column(
      children: [
        Stack(
          children: [
            SizedBox(
              width: radius * 2,
              height: radius * 2,
              child: CircularProgressIndicator(
                strokeWidth: strokeWidth,
                backgroundColor: const Color.fromARGB(154, 177, 177, 177),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 97, 226, 102),
                ),
                value: progressValue,
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '$count',
                  style: TextStyle(fontSize: fontSize),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        Text(
          label,
          style: const TextStyle(color: Colors.black),
        ),
      ],
    );
  }
}

class NoteCardSliders extends StatelessWidget {
  final List<String> imageUrls = [
    'assets/images/dash1.png', // Gambar 1
    'assets/images/dash2.png', // Gambar 2
    'assets/images/dash3.png', // Gambar 3
  ];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(top: 43), // Sesuaikan padding di sini
        child: CarouselSlider(
          items: imageUrls.map((imageUrl) {
            return buildNoteCard(imageUrl);
          }).toList(),
          options: CarouselOptions(
            aspectRatio: 16 / 9,
            viewportFraction: 0.9,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 10),
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
