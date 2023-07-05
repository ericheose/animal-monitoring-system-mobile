import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/auth.dart';

Future<void> signOut() async {
  await Auth().signOut();
}

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final User? user = Auth().currentUser;

  TopBar({
    super.key,
  });

  Widget _logo() {
    return Image.asset(
      'assets/images/SPCA-logo-white.png',
    );
  }

  Widget _userUid() {
    return Text(user?.email ?? 'user email');
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xff1976D2),
      leading: _logo(),
      leadingWidth: 100,
      title: _userUid(),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
          onPressed: () {
            signOut();
          },
        )
      ],
    );
  }
}
