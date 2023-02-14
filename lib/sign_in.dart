import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo/dashboard.dart';
import 'package:todo/sign_up.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _signInFormKey = GlobalKey<FormState>();
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
              _buildSignInForm(),
              _buildSignUpButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    return Form(
      key: _signInFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        child: Column(
          children: [
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
                if(_signInFormKey.currentState != null && _signInFormKey.currentState!.validate()) {
                  performSignIn();
                }
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> performSignIn() async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      print('...user_id: ${credential.user?.uid}');

      if(!mounted) return;

      // Navigator.pop(context);
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const Dashboard()));

    } on FirebaseAuthException catch(e) {
      if(e.code == 'user-not-found') {
        showSnackBar('No user found. Try to sign up');
      } else if(e.code == 'wrong-password') {
        showSnackBar('Wrong password!');
      }
    } catch (e) {
      print(e);
    }
  }

  void showSnackBar(String msg) {
    final snackbar = SnackBar(content: Text(msg));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  Widget _buildSignUpButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?"),
        const SizedBox(
          width: 4,
        ),
        TextButton(onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUp()));
        }, child: const Text('Sign Up'))
      ],
    );
  }
}
