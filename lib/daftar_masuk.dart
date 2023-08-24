import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tugas_akhir_flutter/data.dart';
import 'package:tugas_akhir_flutter/register.dart';
import 'package:tugas_akhir_flutter/login.dart' as login;

void main() {
  runApp(const MyApp());
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

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      _animationController.reverse();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _signOutGoogle() async {
    final googleSignIn = GoogleSignIn();
    try {
      await googleSignIn.signOut();
    } catch (e) {
      debugPrint('Error signing out from Google: $e');
    }
  }

  Future<void> _registerWithGoogle(BuildContext context) async {
    try {
      await _signOutGoogle();
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final authResult =
            await FirebaseAuth.instance.signInWithCredential(credential);
        final user = authResult.user;

        if (user != null) {
          Fluttertoast.showToast(
            msg: "Register Successful",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: const Color.fromRGBO(74, 172, 79, 1),
            textColor: Colors.white,
          );

          await Future.delayed(const Duration(seconds: 1));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DataPage(),
            ),
          );
        } else {
          debugPrint('Failed to register with Google');
          Fluttertoast.showToast(
            msg: "Failed to register with Google",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } else {
        debugPrint('Failed to register with Google');
        Fluttertoast.showToast(
          msg: "Failed to register with Google",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error register with Google: $e');
      Fluttertoast.showToast(
        msg: "Error register with Google. Please try again later.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _showRegistrationOptions(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              leading: Image.asset(
                'assets/images/google.png',
                width: 24,
                height: 24,
              ),
              title: Text("Register With Google"),
              onTap: () async {
                _registerWithGoogle(context);
              },
            ),
            ListTile(
              leading: Image.asset(
                'assets/images/other.png',
                width: 27,
                height: 27,
              ),
              title: Text("Register With Other Methods"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Welcome",
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Sign up for Metacent now, and exchange your recyclable trash for points that can be redeemed",
              style: const TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 0),
          Expanded(
            child: Center(
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
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showRegistrationOptions(context);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color.fromRGBO(74, 172, 79, 1),
                      minimumSize: const Size(150, 40),
                    ),
                    child: Text("Register"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const login.LoginScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color.fromRGBO(74, 172, 79, 1),
                      backgroundColor: const Color(0xFFEDEDED),
                      minimumSize: const Size(150, 40),
                    ),
                    child: Center(
                      child: Text("Login"),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
