import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/core/blocs/user_bloc.dart';
import 'package:chat_app/core/models/chat_model.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/ui/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class ChatWidget extends StatefulWidget {
  final User user;
  final DocumentSnapshot chatSnapshot;

  const ChatWidget({Key key, this.user, this.chatSnapshot}) : super(key: key);

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  Chat chat;

  ets() async {}

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('conversations')
          .document(widget.chatSnapshot.documentID)
          .collection('messages')
          .orderBy('time')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          chat = Chat(widget.chatSnapshot, snapshot.data);
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => ChatPage(
                            user: widget.user,
                            chatSnapshot: widget.chatSnapshot,
                          )));
            },
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
                        // Where the linear gradient begins and ends
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.blueAccent, Colors.deepOrangeAccent],
                      ),
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(
                            '${widget.user.photoUrl}'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                          child: Text(
                            '${widget.user.name}',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 4),
                                child: chat.messages.last.type
                                    ? Text(
                                        '${chat.messages.last.content}',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: chat.messages.last
                                                        .senderID ==
                                                    userBloc.firebaseUser.uid
                                                ? Colors.blue
                                                : Colors.deepOrange),
                                      )
                                    : Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.camera_alt,
                                            color: chat.messages.last
                                                        .senderID ==
                                                    userBloc.firebaseUser.uid
                                                ? Colors.blue
                                                : Colors.deepOrange,
                                            size: 16,
                                          ),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(left: 4)),
                                          Text(
                                            'Picture',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: chat.messages.last
                                                            .senderID ==
                                                        userBloc
                                                            .firebaseUser.uid
                                                    ? Colors.blue
                                                    : Colors.deepOrange),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 8),
                              child: Text(
                                '${timeAgo.format(chat.lastModified.toDate(), locale: 'en_short')}',
//                                '${DateTime.parse(chat.lastModified)}',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else
          return Center(child: CircularProgressIndicator());
      },
    );
  }
}
