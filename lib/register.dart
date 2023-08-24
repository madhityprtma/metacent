import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_akhir_flutter/login.dart';
import 'package:tugas_akhir_flutter/utama.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _passwordVisible = false;
  bool _agreedToTerms = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  void _toggleAgreeToTerms(bool? value) {
    setState(() {
      _agreedToTerms = value ?? false;
    });
  }

  Future<void> _register() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String phoneNumber = _phoneNumberController.text.trim();

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions.'),
        ),
      );
      return;
    }

    try {
      final authResult =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = authResult.user;

      if (user != null) {
        Fluttertoast.showToast(
          msg: 'Registration successful',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('name', name);
        prefs.setString('phoneNumber', phoneNumber);
        prefs.setBool('agreedToTerms', true);

        await Future.delayed(const Duration(seconds: 1));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to register with Firebase.'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error registering: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error registering. Please try again later.'),
        ),
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
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Register Page",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            Text(
              "Please fill in the form to join",
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: const OutlineInputBorder(),
              ),
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
                  onPressed: _togglePasswordVisibility,
                ),
                border: const OutlineInputBorder(),
              ),
              obscureText: !_passwordVisible,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                labelText: "Phone Number",
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Checkbox(
                  value: _agreedToTerms,
                  onChanged: _toggleAgreeToTerms,
                ),
                Flexible(
                  child: Text(
                    "I agree to the Terms and Conditions and Privacy Policy",
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _agreedToTerms ? _register : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: const Color.fromRGBO(74, 172, 79, 1),
              ),
              child: Text(
                "Register",
                style: const TextStyle(fontSize: 18.0),
              ),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Already have an account?",
                  style: const TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Login",
                      style: const TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
