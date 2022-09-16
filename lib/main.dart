import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_course/auth/login.dart';
import 'package:firebase_course/auth/signup.dart';
import 'package:firebase_course/crud/add_note.dart';
import 'package:firebase_course/home/home_page.dart';

import 'package:flutter/material.dart';

bool? isLogin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  /// Check if the user logged in before or not
  var signedIn = FirebaseAuth.instance.currentUser;
  signedIn == null ? isLogin = false : isLogin = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: const TextTheme(
            headline6: TextStyle(fontSize: 20, color: Colors.white),
            headline5: TextStyle(fontSize: 30, color: Colors.blue),
            bodyText2: TextStyle(fontSize: 20, color: Colors.black),
          )),
      home: isLogin == false ? Login() : HomePage(),
      //const Test(),
      routes: {
        "login": (context) => Login(),
        "homepage": (context) => HomePage(),
        "signup": (context) => SignUp(),
        "addNotes": (context) => AddNotes(),
      },
    );
  }
}
