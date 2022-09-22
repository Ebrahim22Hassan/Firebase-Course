import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_course/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  dynamic userName, myPassword, myEmail;
  GlobalKey<FormState> formState = GlobalKey<FormState>();

  bool _obscureText = true;

  signUp() async {
    var formData = formState.currentState;
    if (formData!.validate()) {
      formData.save();
      try {
        UserCredential credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: myEmail,
          password: myPassword,
        );
        return credential;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          Navigator.of(context).pop();
          AwesomeDialog(
            context: context,
            body: const Text('The password is too weak'),
          ).show();
          debugPrint('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          Navigator.of(context).pop();
          AwesomeDialog(
            context: context,
            body: const Text('The account already exists for that email'),
          ).show();
          debugPrint('The account already exists for that email.');
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      debugPrint('Not Valid');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formState,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      prefix: Icon(Icons.person),
                      hintText: "username",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                    onSaved: (value) {
                      userName = value;
                    },
                    validator: (val) {
                      if (val!.length > 100) {
                        return "username can't to be larger than 100 letter";
                      }
                      if (val.length < 2) {
                        return "username can't to be less than 2 letter";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      prefix: Icon(Icons.mail),
                      hintText: "mail",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                    onSaved: (value) {
                      myEmail = value;
                    },
                    validator: (val) {
                      if (val!.length > 100) {
                        return "username can't to be larger than 100 letter";
                      }
                      if (val.length < 2) {
                        return "username can't to be less than 2 letter";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    decoration: InputDecoration(
                      prefix: const Icon(Icons.lock),
                      hintText: "password",
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                      prefixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          icon: Icon(_obscureText
                              ? Icons.visibility_off
                              : Icons.visibility)),
                    ),
                    obscureText: _obscureText,
                    onSaved: (value) {
                      myPassword = value;
                    },
                    validator: (val) {
                      if (val!.length > 100) {
                        return "username can't to be larger than 100 letter";
                      }
                      if (val.length < 8) {
                        return "username can't to be less than 2 letter";
                      }
                      return null;
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        const Text('If you have account '),
                        InkWell(
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                          onTap: () {
                            //Navigator.of(context).pushNamed("login");
                            Get.to(
                              () => const Login(),
                              transition: Transition.leftToRight,
                              duration: const Duration(seconds: 1),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      UserCredential response = await signUp();
                      if (response != null) {
                        await FirebaseFirestore.instance
                            .collection("users")
                            .add({
                          "name": userName,
                          "email": myEmail,
                        });
                        if (!mounted) return;
                        Navigator.of(context).pushReplacementNamed("homepage");
                        debugPrint(response.user!.email);
                      } else {
                        debugPrint('Not Valid');
                      }
                    },
                    child: Text(
                      'Sign Up',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
