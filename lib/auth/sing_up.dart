import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseflutter/auth/sing_in.dart';
import 'package:firebaseflutter/home.dart';
import 'package:firebaseflutter/profile.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/text_field_obscure.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  GlobalKey<FormState> _key = GlobalKey();

  TextEditingController _passwordController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  bool isObscure = true;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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
                    'Регистрация',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26),
                  ),
                  const Spacer(),
                  TextFormField(
                    maxLength: 32,
                    controller: _emailController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Поле с почтой пустое';
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
                  const SizedBox(height: 20),
                  TextFormField(
                    maxLength: 8,
                    controller: _passwordController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Поле пароль пустое';
                      }
                      if (value.contains(" ")) {
                        return 'Пароль не должен содержать пробелы';
                      }
                      return null;
                    },
                    obscureText: isObscure,
                    decoration: InputDecoration(
                      hintText: 'Пароль',
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
                    content: 'Регистрация',
                    onPressed: () {
                      if (_key.currentState!.validate()) {
                        signUp();
                      } else {}
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

  void signUp() async {
    try{
    final auth = FirebaseAuth.instance;
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);

      userCredential = await auth.signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);

      final finance = firestore.collection('Users');

      finance.doc(auth.currentUser?.uid.toString()).set(
        {'Email': _emailController.text, 'Password': _passwordController.text},
      ).then((value) => {setState(() {})});
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showAlertDialog(context, 'Пароль слишком слабый');
      } else if (e.code == 'email-already-in-use') {
        showAlertDialog(
            context, 'Этот адрес электронной почты уже используется');
      } else
        showAlertDialog(context, e.toString());

        Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeAdmin()),
      );
    }
    } catch (e) {
      showAlertDialog(context, e.toString());
    }
  }
}
