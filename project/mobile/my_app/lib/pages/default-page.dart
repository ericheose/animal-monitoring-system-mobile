import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:my_app/auth.dart';
import '../widgets/custom_appbar.dart';

import 'package:my_app/pages/message-page.dart';
import 'package:my_app/pages/dashboard-page.dart';
import 'package:my_app/pages/weigh-pet-page.dart';
import 'package:my_app/pages/pet-directory-page.dart';

class DefaultPage extends StatefulWidget {
  @override
  _DefaultPageState createState() => _DefaultPageState();
  const DefaultPage({Key? key}) : super(key: key);
}

class _DefaultPageState extends State<DefaultPage> {
  //Wigets
  final User? user = Auth().currentUser;

  int _selectedIndex = 0;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _title() {
    return const Text('Firebase Auth');
  }

  Widget _userUid() {
    return Text(user?.email ?? 'user email');
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign Out'),
    );
  }

  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _navBar(context) {
    return Container(
      color: const Color(0xffeaeaea),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        child: GNav(
          rippleColor: const Color(0xff1976d2),
          hoverColor: const Color(0xff1976d2),
          curve: Curves.easeOutExpo,
          backgroundColor: const Color(0xffeaeaea),
          color: const Color(0xff1976d2),
          activeColor: Colors.white,
          tabBackgroundColor: const Color(0xff1976d2),
          gap: 8,
          onTabChange: (index) {
            setSelectedIndex(index);
            // if (index == 1) {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => MessagesPage()),
            //   );
            //   setSelectedIndex(index);
            //   // mainbottomNav.setSelectedItemId(R.id.bottom_action_account);
            // }
          },
          padding: const EdgeInsets.all(10),
          tabs: const [
            GButton(
              icon: Icons.home,
              text: 'Home',
            ),
            GButton(
              icon: Icons.chat,
              text: 'Messages',
            ),
            GButton(
              icon: Icons.assignment_add,
              text: 'Weigh Pet',
            ),
            GButton(
              icon: Icons.subdirectory_arrow_right_rounded,
              text: 'Pet Directory',
            ),
          ],
        ),
      ),
    );
  }

  final List<Widget> _pageList = <Widget>[
    const DashboardPage(),
    const MessagesPage(),
    const WeighPetPage(),
    const PetDirectoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: TopBar(),
        bottomNavigationBar: _navBar(context),
        body: SizedBox.expand(
          child: _pageList.elementAt(_selectedIndex),
        ),
      ),
    );
  }
}
