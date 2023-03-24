import 'dart:html';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseflutter/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class finances extends StatefulWidget {
  const finances({Key? key}) : super(key: key);

  @override
  State<finances> createState() => _FinancesState();
}

class _FinancesState extends State<finances> {
  GlobalKey<FormState> _key = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _nameOperationController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _summController = TextEditingController();

  List<String> idlist = <String>[];
  List<bool> listispressed = <bool>[];
  String selectedDocument = "";

  DateTime currentDate = DateTime.now();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(2015),
        lastDate: DateTime(2050));
    if (pickedDate != null && pickedDate != currentDate)
      setState(() {
        currentDate = pickedDate;
      });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final finances = FirebaseFirestore.instance
      .collection('Finances')
      .withConverter<FinancesModel>(
        fromFirestore: (snapshots, _) =>
            FinancesModel.fromJson(snapshots.data()!),
        toFirestore: (finance, _) => finance.toJson(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 300,
                      child: StreamBuilder<QuerySnapshot<FinancesModel>>(
                        stream: finances.snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(snapshot.error.toString()),
                            );
                          }
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final data = snapshot.requireData;

                          return ListView.builder(
                            itemCount: data.size,
                            itemBuilder: (context, index) {
                              idlist.add(data.docs[index].reference.id);
                              listispressed.add(false);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    for (int i = 0;
                                        i < listispressed.length;
                                        i++) {
                                      listispressed[i] = false;
                                    }
                                    listispressed[index] =
                                        !listispressed[index];
                                  });
                                },
                                child: Container(
                                  color: listispressed[index]
                                      ? Colors.red[100]
                                      : Colors.white,
                                  child: Center(
                                    child: _FinanceItem(
                                      data.docs[index].data(),
                                      data.docs[index].reference,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Form(
                              key: _key,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(children: [
                                      Container(
                                        width: 300,
                                        height: 80,
                                        child: TextFormField(
                                          maxLength: 20,
                                          controller: _nameOperationController,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Поле название пустое';
                                            }
                                            if (value.length < 3) {
                                              return 'Название должно быть больше 3 символов';
                                            }
                                            return null;
                                          },
                                          decoration: const InputDecoration(
                                            hintText: 'Название',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 300,
                                        height: 80,
                                        child: TextFormField(
                                          maxLength: 250,
                                          controller: _descriptionController,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Поле описания пустое';
                                            }
                                            if (value.length < 5) {
                                              return 'Описание должно быть больше 5 символов';
                                            }
                                            return null;
                                          },
                                          decoration: const InputDecoration(
                                            hintText: 'Описание',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      Column(children: [
                                        Container(
                                            height: 40,
                                            width: 300,
                                            child: Text(currentDate.year
                                                    .toString() +
                                                "/" +
                                                currentDate.month.toString() +
                                                "/" +
                                                currentDate.day.toString())),
                                        Container(
                                          height: 40,
                                          width: 300,
                                          child: ElevatedButton(
                                            onPressed: () =>
                                                _selectDate(context),
                                            child: Text('Дата операции'),
                                          ),
                                        ),
                                      ]),
                                      Container(
                                        height: 80,
                                        width: 300,
                                        child: TextField(
                                          controller: _summController,
                                          decoration: new InputDecoration(
                                              labelText: "Сумма"),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                        ),
                                      ),
                                    ]),
                                  ]),
                            ),
                            Container(
                              child: Column(children: [
                                Container(
                                  width: 200,
                                  child: CustomButton(
                                    content: 'Добавить',
                                    onPressed: () {
                                      if (_key.currentState!.validate()) {
                                        addFinance();
                                      } else {}
                                    },
                                  ),
                                ),
                                SizedBox(height: 20),
                                Container(
                                  width: 200,
                                  child: CustomButton(
                                    content: 'Изменить',
                                    onPressed: () {
                                      if (_key.currentState!.validate()) {
                                        EditFinance();
                                      } else {}
                                    },
                                  ),
                                ),
                                SizedBox(height: 20),
                                Container(
                                  width: 200,
                                  child: CustomButton(
                                    content: 'Удалить',
                                    onPressed: () {
                                      DeleteFinance();
                                    },
                                  ),
                                ),
                              ]),
                            )
                          ]),
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  void addFinance() {
    try {
      final finance = firestore.collection('Finances');

      finance
          .add(
            {
              'name': _nameOperationController.text,
              'description': _descriptionController.text,
              'date': currentDate.year.toString() +
                  "/" +
                  currentDate.month.toString() +
                  "/" +
                  currentDate.day.toString(),
              'summ': _summController.text,
              'user_id': getCurrentUser()?.uid
            },
          )
          .then((value) => {setState(() {})})
          .catchError((error) => showAlertDialog(context));
    } catch (exception) {
      print(exception);
      showAlertDialog(context);
    }
  }

  void EditFinance() async {
    try {
      final finance = firestore.collection('Finances');
      String docsel = "";
      for (int i = 0; i < listispressed.length; i++) {
        if (listispressed[i] == true) {
          docsel = idlist[i].toString();
        }
      }
      if (docsel != "") {
        finance
            .doc(docsel)
            .set({
              'name': _nameOperationController.text,
              'description': _descriptionController.text,
              'date': currentDate.year.toString() +
                  "/" +
                  currentDate.month.toString() +
                  "/" +
                  currentDate.day.toString(),
              'summ': _summController.text,
              'user_id': getCurrentUser()?.uid
            })
            .then((value) => {setState(() {})})
            .catchError((error) => showAlertDialog(context));
      }
    } catch (exception) {
      print(exception);
      showAlertDialog(context);
    }
  }

  void DeleteFinance() async {
    try {
      final finance = firestore.collection('Finances');
      String docsel = "";
      for (int i = 0; i < listispressed.length; i++) {
        if (listispressed[i] == true) {
          docsel = idlist[i].toString();
        }
      }
      if (docsel != "") {
        finance
            .doc(docsel)
            .delete()
            .then((value) => {setState(() {})})
            .catchError((error) => showAlertDialog(context));
      }
    } catch (exception) {
      print(exception);
      showAlertDialog(context);
    }
  }
}

showAlertDialog(BuildContext context) {
  // set up the button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Ошибка!"),
    content: Text("Ошибка"),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

@immutable
class FinancesModel {
  FinancesModel({
    required this.name,
    required this.description,
    required this.date,
    required this.summ,
    required this.user_id,
  });

  FinancesModel.fromJson(Map<String, Object?> json)
      : this(
          name: json['name']! as String,
          description: json['description']! as String,
          date: json['date']! as String,
          summ: json['summ']! as String,
          user_id: json['user_id']! as String,
        );

  final String name;
  final String summ;
  final String description;
  final String user_id;
  final String date;

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'summ': summ,
      'description': description,
      'user_id': user_id,
      'date': date,
    };
  }
}

class _FinanceItem extends StatelessWidget {
  _FinanceItem(this.finance, this.reference);

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  final FinancesModel finance;
  final DocumentReference<FinancesModel> reference;

  /// Returns the movie poster.
  Widget get name {
    return SizedBox(
      child: Text(
        '${finance.name} от даты: ${finance.date}',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Returns movie details.
  Widget get description {
    return SizedBox(
      child: Text(finance.description),
    );
  }

  Widget get summ {
    return SizedBox(
      width: 100,
      child: Text(finance.summ.toString()),
    );
  }

  /// Returns metadata about the movie.

  @override
  Widget build(BuildContext context) {
    if (finance.user_id == getCurrentUser()?.uid) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4, top: 4),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [name, description, summ],
          ),
        ),
      );
    } else
      return Container();
  }
}
