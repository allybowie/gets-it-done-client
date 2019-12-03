import 'package:flutter/material.dart';
import 'package:gets_it_done/screens/authenticate/auth_toggle.dart';
import 'package:gets_it_done/screens/authenticate/login.dart';
import 'package:gets_it_done/screens/authenticate/sign_up.dart';
import 'package:gets_it_done/screens/home/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}