import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tugas_akhir_flutter/data.dart';
import 'package:tugas_akhir_flutter/lupa.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _passwordVisible = false;
  bool _rememberMe = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkRememberMe();
  }

  void _checkRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool rememberMe = prefs.getBool('rememberMe') ?? false;

    if (rememberMe) {
      _login();
    }
  }

  Future<void> _login() async {
    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        Fluttertoast.showToast(
          msg: "Email and password cannot be empty.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      final authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = authResult.user;

      if (user != null) {
        Fluttertoast.showToast(
          msg: "Login Successful",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        if (_rememberMe) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('rememberMe', true);
        }

        await Future.delayed(const Duration(seconds: 1));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DataPage(),
          ),
        );
      } else {
        Fluttertoast.showToast(
          msg: "Failed to login.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error logging in: $e');
      Fluttertoast.showToast(
        msg: "Error logging in. Please try again later.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _signOutGoogle() async {
    final googleSignIn = GoogleSignIn();
    try {
      await googleSignIn.signOut();
    } catch (e) {
      debugPrint('Error signing out from Google: $e');
    }
  }

  Future<void> _loginWithGoogle() async {
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

        final authResult = await FirebaseAuth.instance.signInWithCredential(credential);
        final user = authResult.user;

        if (user != null) {
          Fluttertoast.showToast(
            msg: "Login Successful",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
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
          debugPrint('Failed to sign in with Google.');
          Fluttertoast.showToast(
            msg: "Failed to sign in with Google.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } else {
        debugPrint('Failed to sign in with Google.');
        Fluttertoast.showToast(
          msg: "Failed to sign in with Google.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      Fluttertoast.showToast(
        msg: "Error signing in with Google. Please try again later.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "Login",
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                "Please input your email and password",
                style: const TextStyle(fontSize: 16.0),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                obscureText: !_passwordVisible,
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (bool? value) {
                      setState(() {
                        _rememberMe = !_rememberMe;
                      });
                    },
                  ),
                  Text("Remember me"),
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: const Color.fromRGBO(74, 172, 79, 1),
                ),
                child: Text(
                  "Login",
                  style: const TextStyle(fontSize: 18.0),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton.icon(
                onPressed: _loginWithGoogle,
                icon: Image.asset(
                  'assets/images/google.png',
                  width: 24.0,
                  height: 24.0,
                ),
                label: Text(
                  "Login With Google",
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
              const SizedBox(height: 16.0),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Forgot Password?",
                  style: const TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Click Here",
                      style: const TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen(),
                            ),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
