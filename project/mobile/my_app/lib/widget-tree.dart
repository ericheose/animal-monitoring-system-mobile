import 'package:my_app/auth.dart';
import 'package:my_app/pages/default-page.dart';
import 'package:my_app/pages/login-page.dart';
import 'package:flutter/material.dart';
import 'database_service.dart';
import 'package:provider/provider.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {

  final dbService = DatabaseService(); // Initialize your DatabaseService here

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DatabaseService>.value(
      value: dbService,
      child: StreamBuilder(
        stream: Auth().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data;
            // Once you have the user data from your Auth, you can set the uid
            if (user != null) {
              dbService.uid = user.uid;
            } 
            return const DefaultPage();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
