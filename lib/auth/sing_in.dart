import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseflutter/auth/sing_up.dart';
import 'package:firebaseflutter/home.dart';
import 'package:firebaseflutter/profile.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/text_field_obscure.dart';
import 'linkmail.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  GlobalKey<FormState> _key = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _loginController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController maintxt = TextEditingController();
  bool isObscure = true;
  bool _isValid = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Form(
            key: _key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Expanded(child: SizedBox()),
                const Text(
                  "Авторизация",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26),
                ),
                const Expanded(child: SizedBox()),
                TextFormField(
                  controller: _loginController,
                  validator: (value) {
                    if (!_isValid) {
                      return null;
                    }
                    if (value!.isEmpty) {
                      return 'Поле почты пустое';
                    }
                    if (value.length < 3) {
                      return 'Почта должна быть не менее 3 символов';
                    }
                    if (value.contains(" ")) {
                      return 'Почта не должна содержать пробелы';
                    }
                    return null;
                  },
                  maxLength: 32,
                  decoration: const InputDecoration(
                    labelText: 'Почта',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  validator: (value) {
                    if (!_isValid) {
                      return null;
                    }
                    if (value!.isEmpty) {
                      return 'Поле пароль пустое';
                    }
                    if (value.contains(" ")) {
                      return 'Пароль не должен содержать пробелы';
                    }
                    return null;
                  },
                  maxLength: 8,
                  obscureText: isObscure,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    suffixIcon: TextFieldObscure(
                        iconColor: Colors.blue,
                        isObscure: (value) {
                          setState(() {
                            isObscure = value;
                          });
                        }),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  content: 'Войти',
                  onPressed: () {
                    _isValid = true;
                    if (_key.currentState!.validate()) {
                      signIn();
                    } else {}
                  },
                ),
                const SizedBox(height: 20),
                CustomButton(
                  content: 'Регистрация',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUp()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                CustomButton(
                  content: 'Войти анонимно',
                  onPressed: () {
                    anonymous();
                  },
                ),
                const SizedBox(height: 20),
                CustomButton(
                  content: 'Войти по ссылке',
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LinkMail()));
                  },
                ),
                const Expanded(flex: 3, child: SizedBox()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void signIn() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _loginController.text, password: _passwordController.text);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeAdmin()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showAlertDialog(context, 'Пользовательне не найден');
      } else if (e.code == 'wrong-password') {
        showAlertDialog(context, 'Неверный пароль');
      } else
        showAlertDialog(context, e.toString());
    }
  }

  void anonymous() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeAdmin()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showAlertDialog(context, 'Пользовательне не найден');
      } else if (e.code == 'wrong-password') {
        showAlertDialog(context, 'Неверный пароль');
      } else
        showAlertDialog(context, e.toString());
    }
  }

  void linkmail() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeAdmin()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showAlertDialog(context, 'Пользовательне не найден');
      } else if (e.code == 'wrong-password') {
        showAlertDialog(context, 'Неверный пароль');
      } else
        showAlertDialog(context, e.toString());
    }
  }
}

showAlertDialog(BuildContext context, String message) {
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text("Ошибка!"),
    content: Text(message),
    actions: [
      okButton,
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
