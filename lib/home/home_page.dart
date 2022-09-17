import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_course/crud/edit_note.dart';
import 'package:firebase_course/crud/view_note.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CollectionReference notesRef = FirebaseFirestore.instance.collection("notes");

  getUser() {
    var user = FirebaseAuth.instance.currentUser;
    print(user!.email);
  }

  var fbm = FirebaseMessaging.instance;

  initialMessage() async {
    var message = await FirebaseMessaging.instance.getInitialMessage();

    if (message != null) {
      Navigator.of(context).pushNamed("addNotes");
    }
  }

  requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  @override
  void initState() {
    requestPermission();
    initialMessage();
    fbm.getToken().then((token) {
      print("=================== Token ==================");
      print(token);
      print("====================================");
    });

    FirebaseMessaging.onMessage.listen((event) {
      print(
          "===================== data Notification ==============================");

      //  AwesomeDialog(context: context , title: "title" , body: Text("${event.notification.body}"))..show() ;

      Navigator.of(context).pushNamed("addNotes");
    });

    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomePage'),
        actions: [
          IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed("login");
              })
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).pushNamed("addNotes");
          }),
      body: FutureBuilder<QuerySnapshot>(
        future: notesRef
            .where("userid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .get(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  // Swipe to delete
                  key: UniqueKey(),
                  onDismissed: (_) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text(
                            "Are you sure you want to delete this note?",
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("No")),
                            ElevatedButton(
                                onPressed: () async {
                                  ///Delete Note
                                  await notesRef
                                      .doc(snapshot.data!.docs[index].id)
                                      .delete();

                                  ///Delete image as well
                                  await FirebaseStorage.instance
                                      .refFromURL(snapshot.data!.docs[index]
                                          ['imageUrl'])
                                      .delete();

                                  ///skip alert dialog
                                  Navigator.pop(context);
                                },
                                child: const Text("Yes")),
                          ],
                        );
                      },
                    );
                  },
                  background: Container(
                      alignment: Alignment.centerLeft,
                      color: Colors.red,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Icon(
                          Icons.delete_forever,
                          color: Colors.white,
                        ),
                      )),
                  secondaryBackground: Container(
                      alignment: Alignment.centerRight,
                      color: Colors.red,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Icon(
                          Icons.delete_rounded,
                          color: Colors.white,
                        ),
                      )),
                  child: ListNotes(
                    notes: snapshot.data!.docs[index],

                    /// To get document ID
                    docId: snapshot.data!.docs[index].id,
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class ListNotes extends StatelessWidget {
  final dynamic notes;
  final dynamic docId;

  const ListNotes({super.key, this.notes, this.docId});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return ViewNotes(notes: notes);
        }));
      },
      child: Card(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Image.network(
                "${notes['imageUrl']}",
                fit: BoxFit.fill,
                height: 80,
              ),
            ),
            Expanded(
              flex: 3,
              child: ListTile(
                title: Text(
                  "${notes['title']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  "${notes['note']}",
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                ),
                trailing: IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return EditNotes(
                        docId: docId,
                        list: notes,
                      );
                    }));
                  },
                  icon: Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 0.1,
                          ),
                        ]),
                    child: const Icon(
                      Icons.edit,
                      size: 28,
                    ),
                  ),
                  color: Colors.blue,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
