import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/core/blocs/chats_bloc.dart';
import 'package:chat_app/core/blocs/user_bloc.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/ui/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

class PersonWidget extends StatefulWidget {
  final User user;

  const PersonWidget({Key key, this.user}) : super(key: key);

  @override
  _PersonWidgetState createState() => _PersonWidgetState();
}

class _PersonWidgetState extends State<PersonWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => startConversation(),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 50,
              width: 50,
              margin: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blueAccent, Colors.deepOrangeAccent],
                  ),
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image:
                        CachedNetworkImageProvider('${widget.user.photoUrl}'),
                  )),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                    child: Text(
                      '${widget.user.name}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                    child: Text(
                      '${widget.user.email}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  startConversation() async {
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(
        progressWidget: Center(child: CircularProgressIndicator()),
        message: 'Loading chat...',
        borderRadius: 8);
    pr.show();
    DocumentSnapshot chatSnapshot = await chatsBloc
        .startConversation([userBloc.firebaseUser.uid, widget.user.id]);
    pr.dismiss();
    if (chatSnapshot != null)
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => ChatPage(
                    user: widget.user,
                    chatSnapshot: chatSnapshot,
                  )));
  }
}
