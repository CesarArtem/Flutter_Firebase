import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseflutter/auth/sing_in.dart';
import 'package:flutter/material.dart';

import '../profile.dart';
import '../widgets/custom_button.dart';

class LinkMail extends StatefulWidget {
  const LinkMail({Key? key}) : super(key: key);

  @override
  State<LinkMail> createState() => _LinkMailState();
}

class _LinkMailState extends State<LinkMail> {
  GlobalKey<FormState> _key = GlobalKey();

  TextEditingController _passwordController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Form(
            key: _key,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  const Text(
                    'Вход через ссылку',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26),
                  ),
                  const Spacer(),
                  TextFormField(
                    maxLength: 32,
                    controller: _emailController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Поле с поччтой пустое';
                      }
                      if (value.contains(" ")) {
                        return 'Почта не должна содержать пробелы';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Почта',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    maxLength: 32,
                    controller: _passwordController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Поле с ссылкой пустое';
                      }
                      if (value.contains(" ")) {
                        return 'Ссылка не должна содержать пробелы';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Ссылка',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    content: 'Войти',
                    onPressed: () {
                        sendLink();
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    content: 'Вернуться',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignIn()),
                      );
                    },
                  ),
                  const Spacer(flex: 3),
                ]),
          ),
        ),
      ),
    );
  }
  
  void sendLink() async{
final FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      ActionCodeSettings actionCodeSettings = ActionCodeSettings(
        url: 'https://linkmailtaransuperuser.page.link/Zi7X',
        androidMinimumVersion: "16",
        androidPackageName: "com.example.app",
        handleCodeInApp: true,);
      await _auth.sendSignInLinkToEmail(email: _emailController.text, actionCodeSettings: actionCodeSettings);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Profile()),
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