import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_course/crud/edit_note.dart';
import 'package:firebase_course/crud/view_note.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.all(50.0),
          child: Text('Home Page'),
        ),
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
                return Slidable(
                  startActionPane: ActionPane(
                    extentRatio: 0.6,
                    motion: const StretchMotion(),
                    children: [
                      SlidableAction(
                          backgroundColor: Colors.black12,
                          label: 'close',
                          icon: Icons.close,
                          onPressed: (_) {}),
                      SlidableAction(
                          backgroundColor: Colors.red,
                          label: 'delete',
                          icon: Icons.delete,
                          onPressed: (_) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text(
                                    "Delete note?",
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
                                              .doc(
                                                  snapshot.data!.docs[index].id)
                                              .delete();

                                          ///Delete image as well
                                          await FirebaseStorage.instance
                                              .refFromURL(snapshot.data!
                                                  .docs[index]['imageUrl'])
                                              .delete();

                                          ///skip alert dialog
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Yes")),
                                  ],
                                );
                              },
                            );
                          }),
                    ],
                  ),
                  endActionPane: ActionPane(
                    extentRatio: 0.6,
                    motion: const StretchMotion(),
                    children: [
                      SlidableAction(
                          backgroundColor: Colors.green,
                          label: 'edit',
                          icon: Icons.edit,
                          onPressed: (_) {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return EditNotes(
                                docId: snapshot.data!.docs[index].id,
                                list: snapshot.data!.docs[index],
                              );
                            }));
                          }),
                      SlidableAction(
                          backgroundColor: Colors.black12,
                          label: 'close',
                          icon: Icons.close,
                          onPressed: (_) {}),
                    ],
                  ),
                  child: ListNotes(
                    notes: snapshot.data!.docs[index],

                    /// To get document ID
                    docId: snapshot.data!.docs[index].id,
                  ),
                );
                // );
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
    return Card(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Image.network(
              "${notes['imageUrl']}",
              fit: BoxFit.fill,
              height: 120,
            ),
          ),
          Expanded(
            flex: 3,
            child: ListTile(
              title: Text("${notes['title']}"),
              subtitle: Text(
                "${notes['note']}",
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
              ),
              trailing: IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return ViewNotes(notes: notes);
                  }));
                },
                icon: const Icon(
                  Icons.event_note,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
