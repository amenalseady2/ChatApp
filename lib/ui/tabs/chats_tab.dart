import 'package:chat_app/core/blocs/user_bloc.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/ui/widgets/chat_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatsTab extends StatefulWidget {
  @override
  _ChatsTabState createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder(
        stream: Firestore.instance
            .collection('conversations')
//            .where('users', arrayContains: userBloc.firebaseUser.uid)
            .orderBy('last_modified', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          print('snapshot ${snapshot.toString()}');
          if (snapshot.hasData) {
            List<DocumentSnapshot> documents = snapshot.data.documents
                .where(
                    (d) => d.data['users'].contains(userBloc.firebaseUser.uid))
                .toList();
            return ListView.separated(
                itemBuilder: (context, index) {
                  List<dynamic> users = documents[index].data['users'];
                  users = users.where((u) {
                    return u != userBloc.firebaseUser.uid;
                  }).toList();
                  return Container(
                    child: StreamBuilder(
                      stream: Firestore.instance
                          .collection('users')
                          .document(users.first)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                        if (userSnapshot.hasData) {
                          User user = User(userSnapshot.data);

                          return ChatWidget(
                            user: user,
                            chatSnapshot: documents[index],
                          );
                        } else
                          return Container(
                            child: Center(child: CircularProgressIndicator()),
                            height: 75,
                          );
                      },
                    ),
                  );
                },
                separatorBuilder: (context, index) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.blueAccent, Colors.deepOrangeAccent],
                        ),
                      ),
                      height: 0.2,
                      margin: EdgeInsets.symmetric(horizontal: 25),
                    ),
                itemCount: documents.length);
          } else
            return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
