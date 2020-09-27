import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      accentColor: Colors.orange,
    ),
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // エラー時に表示するWidget
        if (snapshot.hasError) {
          return Container(color: Colors.white);
        }

        // Firebaseのinitialize完了したら表示したいWidget
        if (snapshot.connectionState == ConnectionState.done) {
          return MyHomeApp();
        }

        // Firebaseのinitializeが完了するのを待つ間に表示するWidget
        return Container(color: Colors.blue);
      },
    );
  }
}

class MyHomeApp extends StatefulWidget {
  @override
  _MyHomeAppState createState() => _MyHomeAppState();
}

class _MyHomeAppState extends State<MyHomeApp> {
  List todos = List();
  String todoTitle = "";

  createTodos() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('MyTodos').doc(todoTitle);

    // Map
    Map<String, String> todos = {"todoTitle": todoTitle};

    documentReference.set(todos).whenComplete(() {
      print("$todoTitle created");
    });
  }

  deleteTodos(item) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('MyTodos').doc(item);

    documentReference.delete().whenComplete(() {
      print("deleted");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('My Todos'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  title: Text("Add Todolist"),
                  content: TextField(
                    onChanged: (String value) {
                      todoTitle = value;
                    },
                  ),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () {
                          createTodos();

                          Navigator.of(context).pop();
                        },
                        child: Text("Add"))
                  ],
                );
              },
            );
          },
          child: Icon(Icons.add, color: Colors.white),
        ),
        body: StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection("MyTodos").snapshots(),
            builder: (context, snapshots) {
              if (snapshots.data == null) return CircularProgressIndicator();
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshots.data.documents.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot documentSnapshot =
                      snapshots.data.documents[index];
                  return Dismissible(
                    onDismissed: (direction) {
                      deleteTodos(documentSnapshot.get('todoTitle'));
                    },
                    key: Key(documentSnapshot.get('todoTitle')),
                    child: Card(
                      elevation: 4,
                      margin: EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        title: Text(documentSnapshot.get('todoTitle')),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            deleteTodos(documentSnapshot.get('todoTitle'));
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            }));
  }
}
