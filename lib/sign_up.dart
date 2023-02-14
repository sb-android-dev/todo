import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo/dashboard.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _signUpFormKey = GlobalKey<FormState>();

  var name = '';
  var email = '';
  var password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSignUpForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Form(
      key: _signUpFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                label: Text('Name'),
                hintText: 'Enter your name',
              ),
              validator: (value) => (value != null && value.isNotEmpty) ? null : 'Invalid name',
              onChanged: (value) => name = value,
            ),
            TextFormField(
              decoration: const InputDecoration(
                label: Text('Email'),
                hintText: 'Enter your email',
              ),
              validator: (value) => (value != null && value.contains('@')) ? null : 'Invalid email',
              onChanged: (value) => email = value,
            ),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                label: Text('Password'),
                hintText: 'Enter password',
              ),
              validator: (value) => (value != null && value.length >= 6) ? null : 'Password should be at least 6 character long',
              onChanged: (value) => password = value,
            ),
            ElevatedButton(
              onPressed: () {
                if(_signUpFormKey.currentState != null && _signUpFormKey.currentState!.validate()) {
                  performSignUp();
                }
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> performSignUp() async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      print('...user_id: ${credential.user?.uid}');

      if(!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (context) => const Dashboard()));
      Navigator.pop(context);

    } on FirebaseAuthException catch(e) {
      if(e.code == 'weak-password') {
        showSnackBar('Password is too weak');
      } else if(e.code == 'email-already-in-use') {
        showSnackBar('Already a registered user. Try to sign in');
      }
    } catch (e) {
      print(e);
    }
  }

  void showSnackBar(String msg) {
    final snackbar = SnackBar(content: Text(msg));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}
