import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_course/auth/signup.dart';
import 'package:firebase_course/components/alert.dart';
import 'package:firebase_course/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var myPassword, myEmail;
  GlobalKey<FormState> formState = GlobalKey<FormState>();

  bool _obscureText = true;

  signIn() async {
    var formData = formState.currentState;
    if (formData!.validate()) {
      formData.save();

      ///!!
      try {
        showLoading(context);
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: myEmail, password: myPassword);
        return userCredential;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          Navigator.of(context).pop();
          AwesomeDialog(
                  context: context,
                  title: "Error",
                  body: const Text("No user found for that email"))
              .show();
        } else if (e.code == 'wrong-password') {
          Navigator.of(context).pop();
          AwesomeDialog(
                  context: context,
                  title: "Error",
                  body: const Text("Wrong password provided for that user"))
              .show();
        }
      }
    } else {
      print("Not Vaild");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Form(
                key: formState,
                child: Column(
                  children: [
                    TextFormField(
                      onSaved: (val) {
                        myEmail = val;
                      },
                      validator: (val) {
                        if (val!.length > 100) {
                          return "Email can't to be larger than 100 letter";
                        }
                        if (val.length < 2) {
                          return "Email can't to be less than 2 letter";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          hintText: "Email",
                          border: OutlineInputBorder(
                              borderSide: BorderSide(width: 1))),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      onSaved: (val) {
                        myPassword = val;
                      },
                      validator: (val) {
                        if (val!.length > 100) {
                          return "Password can't to be larger than 100 letter";
                        }
                        if (val.length < 4) {
                          return "Password can't to be less than 4 letter";
                        }
                        return null;
                      },
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          icon: Icon(_obscureText
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                        hintText: "password",
                        border: const OutlineInputBorder(
                            borderSide: BorderSide(width: 1)),
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            const Text("If you haven't account "),
                            InkWell(
                              onTap: () {
                                // Navigator.of(context)
                                //     .pushReplacementNamed("signup");
                                Get.to(
                                  () => const SignUp(),
                                  transition: Transition.rightToLeft,
                                  duration: const Duration(seconds: 1),
                                );
                              },
                              child: const Text(
                                "Click Here",
                                style: TextStyle(color: Colors.blue),
                              ),
                            )
                          ],
                        )),
                    ElevatedButton(
                      onPressed: () async {
                        var user = await signIn();
                        if (user != null) {
                          // Navigator.of(context)
                          //     .pushReplacementNamed("homepage");
                          Get.to(
                            () => const HomePage(),
                            transition: Transition.circularReveal,
                            duration: const Duration(seconds: 2),
                          );
                        }
                      },
                      child: Text(
                        "Login",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    )
                  ],
                )),
          )
        ],
      ),
    );
  }
}
