import 'package:chat_app/core/blocs/user_bloc.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/ui/widgets/person_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PeopleTab extends StatefulWidget {
  @override
  _PeopleTabState createState() => _PeopleTabState();
}

class _PeopleTabState extends State<PeopleTab> {
  User user = User.empty();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder(
        stream: Firestore.instance
            .collection('users')
            .document(userBloc.firebaseUser.uid)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            user = User(snapshot.data);
            return Container(
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection('users')
                    .orderBy('name')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    print('snapshto data ${snapshot.data.documents.length}');
                    snapshot.data.documents.removeWhere((d) {
                      return d.documentID == user.id;
                    });
                    print('snapshto data ${snapshot.data.documents.length}');
                    return ListView.separated(
                        itemBuilder: (context, index) => PersonWidget(
                              user: User(snapshot.data.documents[index]),
                            ),
                        separatorBuilder: (context, index) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.blueAccent,
                                    Colors.deepOrangeAccent
                                  ],
                                ),
                              ),
                              height: 0.2,
                              margin: EdgeInsets.symmetric(horizontal: 25),
                            ),
                        itemCount: snapshot.data.documents.length);
                  } else
                    return Container(
                      child: Center(child: CircularProgressIndicator()),
                      height: 75,
                    );
                },
              ),
            );
          } else
            return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
