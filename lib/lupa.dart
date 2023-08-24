import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  ForgotPasswordScreen({Key? key}) : super(key: key);

  Future<void> _sendPasswordResetEmail(BuildContext context) async {
    final String email = _emailController.text.trim();

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent.'),
        ),
      );

      _emailController.clear();
    } catch (e) {
      print('Error sending password reset email: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send password reset email.'),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "Forgot Password?",
                  style: const TextStyle(
                      fontSize: 24.0, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                "Insert your email",
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
              ElevatedButton(
                onPressed: () {
                  _sendPasswordResetEmail(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Colors.green,
                  // Add other attributes as needed
                ),
                child: Text(
                  "Send",
                  style: const TextStyle(fontSize: 18.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
