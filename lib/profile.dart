import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth/sing_in.dart';
import 'widgets/custom_button.dart';
import 'widgets/text_field_obscure.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  GlobalKey<FormState> _key = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _loginController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool isObscure = true;
  bool _isValid = true;

  late String accessToken, refreshToken;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    _emailController.text = getCurrentUser()!.email.toString();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Form(
            key: _key,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Профиль',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26),
                  ),
                  SizedBox(height: 50),
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
                  SizedBox(height: 20),
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
                  SizedBox(height: 20),
                  CustomButton(
                    content: 'Сохранить изменения',
                    onPressed: () {
                      _isValid = true;
                      if (_key.currentState!.validate()) {
                        SaveChanges();
                      } else {}
                    },
                  ),
                  SizedBox(height: 20),
                  CustomButton(
                    content: 'Выйти',
                    onPressed: () {
                      signOut();
                    },
                  ),
                  // const Expanded(flex: 3, child: SizedBox()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void signOut() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    await _auth.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignIn()),
    );
  }

  void SaveChanges() async {
    final finance = firestore.collection('Users');

    final FirebaseAuth _auth = FirebaseAuth.instance;

    User? currentuser = _auth.currentUser;

    currentuser?.updateEmail(_emailController.text).then((_) {
      print("Successfully changed email");
    });

    currentuser?.updatePassword(_passwordController.text).then((_) {
      print("Successfully changed password");
    });

    finance.doc(_auth.currentUser?.uid.toString()).set(
      {'Email': _emailController.text, 'Password': _passwordController.text},
    ).then((value) => {setState(() {})});
  }
}
