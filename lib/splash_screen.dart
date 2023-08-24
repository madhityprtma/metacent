import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tugas_akhir_flutter/daftar_masuk.dart';
import 'package:tugas_akhir_flutter/utama.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();

    Timer(
      const Duration(seconds: 2),
      () async {
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          await _animationController.reverse();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        } else {
          _animationController.reverse().then((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MyApp(),
              ),
            );
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/meta.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
