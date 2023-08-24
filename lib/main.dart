// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tugas_akhir_flutter/splash_screen.dart';
import 'package:tugas_akhir_flutter/utama.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
