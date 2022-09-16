import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  UserCredential? userCredential;

  ///1- Get users info from Firebase
  //getData() async {
  // FirebaseFirestore.instance.collection("users").get().then((value) {
  //   for (var element in value.docs) {
  //     print(element.data());
  //     print("=================");
  //   }
  // });
  //   var doc = FirebaseFirestore.instance
  //       .collection('users')
  //       .doc("mcJlybdhWW5VXoKDoIe2");
  //   await doc.get().then((value) {
  //     print(value.id);
  //     print("=================");
  //   });
  // }

  ///2- Firestore Filtering
  // getData() async {
  //   CollectionReference usersref =
  //       FirebaseFirestore.instance.collection("users");
  //   await usersref.get().then((value) {
  //     value.docs.forEach((element) {
  //       print((element.data() as Map)[
  //           'name']); // as Map => because cannot call an indexer [] on an Object.
  //       print((element.data() as Map)['age']);
  //
  //       print((element.data() as Map)['phone']); //
  //       print("======================");
  //     });
  //   });
  // }

  /// 3- Real-time snapshot
  // getData() async {
  //   FirebaseFirestore.instance.collection("users").snapshots().listen((event) {
  //     event.docs.forEach((element) {
  //       print((element.data())['name']);
  //       print((element.data())['age']);
  //       print('========================');
  //     });
  //   });
  // }

  ///4- Add Data
  // addData() async {
  //   CollectionReference usersref =
  //       FirebaseFirestore.instance.collection("users");
  //   //Method 1 (ADD)
  //   // usersref.add({
  //   //   "name": "EBB",
  //   //   "age": "16",
  //   //   "phone": "0588",
  //   // });
  //   ///
  //   //Method 2 (SET doc)
  //   usersref.doc("9876").set({
  //     "name": "REEE",
  //     "age": "26",
  //     "phone": "9876",
  //   });
  // }

  ///5- Update Data
  // updateData() async {
  //   CollectionReference usersref =
  //       FirebaseFirestore.instance.collection("users");
  //   // Method 1 (UPDATE)
  //   usersref.doc("98761").update({
  //     "name": "HHHH",
  //     "age": "37",
  //     "phone": "554444",
  //   }).then((value) {
  //     print("deleted");
  //   }).catchError((e) {
  //     print("============");
  //     print("Error: $e");
  //   });
  // Method 2 (SET & SetOptions)
  //   usersref.doc("9876").set(
  //     {
  //       "name": "GEQ",
  //       "age": "37",
  //     },
  //     SetOptions(
  //       merge: true,
  //     ),
  //   );
  //}

  ///6- Delete Data
  // deleteData() {
  //   CollectionReference useresref =
  //       FirebaseFirestore.instance.collection("users");
  //   useresref.doc('f40UKMOhRdgAnAntYnlv').delete();
  // }

  ///7- Transactions
  // DocumentReference docref =
  //     FirebaseFirestore.instance.collection("users").doc("9876");
  // trans() async {
  //   FirebaseFirestore.instance.runTransaction((transaction) async {
  //     DocumentSnapshot docSnap = await transaction.get(docref);
  //     if (docSnap.exists) {
  //       print("EXIST");
  //       transaction.update(docref, {"name": "YYYE"});
  //     } else {
  //       print("DOESN'T EXIST");
  //     }
  //   });
  // }

  ///8- Batch Write (multiple write (add&update&delete) at the same time)
  // DocumentReference docref =
  //     FirebaseFirestore.instance.collection("users").doc("9876");
  // DocumentReference docref1 = FirebaseFirestore.instance
  //     .collection("users")
  //     .doc("wEf82b2717vj6daSC28S");
  // batchWrite() async {
  //   WriteBatch batch = FirebaseFirestore.instance.batch();
  //   batch.update(
  //       docref,
  //       ({
  //         "age": "22",
  //         "name": "ESQE",
  //       }));
  //   batch.delete(docref1);
  //   batch.commit();
  // }

  ///9- Show data in UI
  CollectionReference usersRef = FirebaseFirestore.instance.collection("users");

  ///Only to show data without FutureBuilder
  //List users = [];
  // getData() async {
  //   var response = await usersRef.get();
  //   response.docs.forEach((element) {
  //     setState(() {
  //       users.add(element.data());
  //     });
  //   });
  //   print(users);
  // }

  @override
  void initState() {
    getImageNames();
    super.initState();
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  ///Firebase Storage
  File? file;
  var imagePicker = ImagePicker();

  /// upload Image
  // uploadImages() async {
  //   var imgPicked = await imagePicker.pickImage(source: ImageSource.camera);
  //   if (imgPicked != null) {
  //     file = File(imgPicked.path);
  //     //var imgName = basename(imgPicked.path);
  //     print(imgPicked.path);
  //     print("======================");
  //
  //     //Start Upload
  //     var storageRef = FirebaseStorage.instance.ref("images/${imgPicked.name}");
  //     await storageRef.putFile(file!);
  //     var imgUrl = storageRef.getDownloadURL();
  //     print("url: $imgUrl");
  //     //End Upload
  //   } else {
  //     print('No Img');
  //   }
  // }

  ///get Image name
  getImageNames() async {
    var ref = await FirebaseStorage.instance
        .ref("images")
        .list(ListOptions(maxResults: 2));
    //get Image name
    ref.items.forEach((element) {
      print(element.name);
      print(element.fullPath);
      print('==================');
    });

    ///get Folder name
    // ref.prefixes.forEach((element) {
    //   print(element.name);
    //   print('==================');
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('TEST'),
      ),
      body:

          ///Future Builder
          //     FutureBuilder<QuerySnapshot>(
          //   future: usersRef.get(),
          //   builder: (context, snapshot) {
          //     if (snapshot.hasData) {
          //       return ListView.builder(
          //         itemCount: snapshot.data!.docs.length,
          //         itemBuilder: (context, index) {
          //           return Text(snapshot.data!.docs[index]['name'].toString());
          //         },
          //       );
          //     } else if (snapshot.hasError) {
          //       return Text("ERROR");
          //     } else if (snapshot.connectionState == ConnectionState.waiting) {
          //       return Text('Loading');
          //     }
          //     return Container();
          //   },
          // ),

          ///Stream Builder (no need to restart app when you update data from Firebase)
          //     StreamBuilder<QuerySnapshot>(
          //   stream: notesRef.snapshots(),
          //   builder: (context, snapshot) {
          //     if (snapshot.hasData) {
          //       return ListView.builder(
          //         itemCount: snapshot.data!.docs.length,
          //         itemBuilder: (context, index) {
          //           return Text(snapshot.data!.docs[index]['title'].toString());
          //         },
          //       );
          //     }
          //     if (snapshot.hasError) {
          //       return Text("ERROR");
          //     } else {
          //       return Text('loading.....');
          //     }
          //   },
          // ),

          ///
          Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () async {
                //await uploadImages();
              },
              child: Text('Press'),
            ),
          ),

          /// Create
          // Center(
          //   child: ElevatedButton(
          //     onPressed: () async {
          //       try {
          //         userCredential = await FirebaseAuth.instance
          //             .createUserWithEmailAndPassword(
          //           email: "tahersalah234@gmail.com",
          //           password: "taher12300",
          //         );
          //       } on FirebaseAuthException catch (e) {
          //         if (e.code == 'weak-password') {
          //           print('The password provided is too weak.');
          //         } else if (e.code == 'email-already-in-use') {
          //           print('The account already exists for that email.');
          //         }
          //       } catch (e) {
          //         print(e);
          //       }
          //     },
          //     child: const Text('Create'),
          //   ),
          // ),

          /// Sign in
          // Center(
          //   child: ElevatedButton(
          //     onPressed: () async {
          //       try {
          //         userCredential =
          //             await FirebaseAuth.instance.signInWithEmailAndPassword(
          //           email: "tahersalah234@gmail.com",
          //           password: "taher12300",
          //         );
          //       } on FirebaseAuthException catch (e) {
          //         if (e.code == 'user-not-found') {
          //           print('No user found for that email.');
          //         } else if (e.code == 'wrong-password') {
          //           print('Wrong password provided for that user.');
          //         }
          //       }
          //       print(userCredential);
          //
          //       /// Email Verification
          //       // if (FirebaseAuth.instance.currentUser!.emailVerified ==
          //       //     false /*userCredential!.user!.emailVerified*/) {
          //       //   final user = FirebaseAuth.instance.currentUser!;
          //       //   await user.sendEmailVerification();
          //       // }
          //     },
          //     child: const Text('Sign in'),
          //   ),
          // ),

          /// Sign in with Google
          // Center(
          //   child: ElevatedButton(
          //     onPressed: () async {
          //       UserCredential cred = await signInWithGoogle();
          //       print(cred);
          //     },
          //     child: const Text('Google Sign in'),
          //   ),
          // ),
        ],
      ),
    );
  }
}
