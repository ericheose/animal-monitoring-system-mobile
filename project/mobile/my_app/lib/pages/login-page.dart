import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = ' ';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _entryField(
    String title,
    TextEditingController controller,
  ) {
    return SizedBox(
      width: 348,
      height: 46,
      child: inputField(title, controller),
    );
  }

  Widget inputField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _errorMessage() {
    // return Text(errorMessage == '' ? '' : '$errorMessage');
    return Text(
      errorMessage == '' ? '' : '$errorMessage',
      softWrap: true,
      maxLines: 4,
      overflow: TextOverflow.fade, // new
      style: const TextStyle(color: Colors.red),
    );
  }

  Widget _signIn() {
    return TextButton(
      onPressed: signInWithEmailAndPassword,
      style: TextButton.styleFrom(
        backgroundColor: const Color(0XFF1976D2),
        padding: const EdgeInsets.all(0),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: const Text(
        'SIGN IN',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _submitButton() {
    return SizedBox(height: 49, width: 327, child: _signIn());
  }

  Widget _logo() {
    return Image.asset(
      'assets/images/logo-SPCA.png',
      scale: 1.7,
    );
  }

  Widget _topBox() {
    return const SizedBox(
      height: 116,
    );
  }

  Widget _middleBox() {
    return const SizedBox(
      height: 40,
    );
  }

  Widget _LogoText() {
    return const Text(
      'Weigh My Paws',
      style: TextStyle(
        fontSize: 43,
        fontWeight: FontWeight.bold,
        color: Color(0XFF296A9D),
      ),
    );
  }

  Widget _betweenText() {
    return const SizedBox(
      height: 22,
    );
  }

  Widget _afterText() {
    return const SizedBox(
      height: 53,
    );
  }

  Widget _afterButton() {
    return const SizedBox(
      height: 63,
    );
  }

  Widget _copyRightText() {
    return const Text(
      'COPYRIGHT \u00a9 SPCA 2023',
      style: TextStyle(
        fontSize: 14,
        color: Color(0XFF6C6C6C),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _topBox(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    _logo(),
                    _middleBox(),
                    _LogoText(),
                    _middleBox(),
                    _entryField('Email', _controllerEmail),
                    _betweenText(),
                    _entryField('Password', _controllerPassword),
                    Container(
                      width: (MediaQuery.of(context).size.width),
                      padding: const EdgeInsets.only(
                          top: 8, bottom: 8, left: 8, right: 8),
                      alignment: Alignment.center,
                      child: Center(
                        child: _errorMessage(),
                      ),
                    ),
                    _afterText(),
                    _submitButton(),
                    _afterButton(),
                    _copyRightText(),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
