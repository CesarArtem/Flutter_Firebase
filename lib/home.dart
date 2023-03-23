import 'package:firebaseflutter/finances.dart';
import 'package:firebaseflutter/profile.dart';
import 'package:flutter/material.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({Key? key, this.index = 0}) : super(key: key);
  final int index;
  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  final listPage = [
    finances(),
    Profile(),
  ];

  int currentIndex = 0;

  List<Widget> content = [];

  List<String> actionNavigatorList = ['', 'add_user', '', ''];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Финансы'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        currentIndex: currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.notes), label: 'Финансы'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Профиль')
        ],
      ),
      body: listPage[currentIndex],
    );
  }
}