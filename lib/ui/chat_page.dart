import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/core/blocs/chat_bloc.dart';
import 'package:chat_app/core/blocs/user_bloc.dart';
import 'package:chat_app/core/models/chat_model.dart';
import 'package:chat_app/core/models/msg_model.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/ui/widgets/chat_appbar.dart';
import 'package:chat_app/ui/widgets/chat_input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final User user;
  final DocumentSnapshot chatSnapshot;

  const ChatPage({Key key, this.user, this.chatSnapshot}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  Chat chat;

  ScrollController _scrollController = new ScrollController();
  AnimationController _controller;

  @override
  void initState() {
    chatBloc.getChat(widget.chatSnapshot.documentID);
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    super.initState();
  }

//  Widget stream = StreamBuilder(
//    stream: Firestore.instance
//        .collection('conversations')
//        .document(widget.chatSnapshot.documentID)
//        .collection('messages')
//        .orderBy('time')
//        .snapshots(),
//    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//      if (snapshot.hasData) {
//        chat = Chat(widget.chatSnapshot, snapshot.data);
//        chat.messages = chat.messages.reversed.toList();
//        print('chat msgss ${chat.messages.length}');
//        return body();
//      } else
//        return Center(child: CircularProgressIndicator());
//    },
//  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: chatAppbar(widget.user, context),
      body: StreamBuilder(
        stream: chatBloc.chatList,
        builder: (context, AsyncSnapshot<Chat> snapshot) {
          if (snapshot.hasData) {
            print('has data');
            chat = snapshot.data;
            print('chatpage ${chat.messages.length}');
            return body();
          } else if (snapshot.hasError) {
            print('has data error');
            return Text(snapshot.error.toString());
          } else
            return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget listView() {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      itemCount: chat.messages.length,
      itemBuilder: (context, index) {
//        return BubbleWidget(
//          chatID: chat.id,
//          msg: chat.messages[index],
//          context: context,
//        );
        return buildBubble(chat.messages[index]);
      },
    );
  }

  Widget body() {
    Widget list = listView();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blueAccent, Colors.deepOrangeAccent],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: list,
          ),
          ChatInput(
            chat: chat,
            user: widget.user,
          ),
        ],
      ),
    );
  }

  Widget buildBubble(Msg msg) {
    var alignment = Alignment.center;
    var mainAxisAlignment = CrossAxisAlignment.center;
    var color = Colors.white;
    var nip = BubbleNip.no;
    double left = 0, right = 0;
    bool longPress = false;

    if (msg.senderID != null) if (msg.senderID == userBloc.firebaseUser.uid) {
      color = Colors.blueAccent;
      alignment = Alignment.centerRight;
      mainAxisAlignment = CrossAxisAlignment.end;
      left = MediaQuery.of(context).size.width / 3;
    } else {
      color = Colors.deepOrangeAccent;
      alignment = Alignment.centerLeft;
      mainAxisAlignment = CrossAxisAlignment.start;
      right = MediaQuery.of(context).size.width / 3;
    }
    if (!msg.type) color = Colors.transparent;

    return GestureDetector(
      onLongPress: () {
        print('longpress ${msg.content}');
        AlertDialog d = AlertDialog(
          title: Text(
              msg.type ? 'Delete Msg \'${msg.content}\'?' : 'Delete Picture?'),
          content: new Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Sent at ${msg.time.toDate()}'),
            ],
          ),
          actions: <Widget>[
            new FlatButton(
              onPressed: () {
                chatBloc.deleteMsg(chat.id, msg.id);
                Navigator.of(context).pop();
              },
              textColor: Colors.red,
              child: const Text('Delete'),
            ),
          ],
        );
        if (msg.senderID == userBloc.firebaseUser.uid)
          showDialog(context: context, builder: (BuildContext context) => d);
        if (_controller.isDismissed) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
        setState(() {
          longPress = !longPress;
        });
      },
      child: Column(
        crossAxisAlignment: mainAxisAlignment,
        children: <Widget>[
          Bubble(
            color: color,
            child: buildMsg(msg),
            elevation: 0,
            margin: BubbleEdges.only(top: 10, left: left, right: right),
            alignment: alignment,
            nip: nip,
            nipRadius: 2,
            padding: BubbleEdges.all(0),
            radius: Radius.circular(16),
          )
        ],
      ),
    );
  }

  Widget buildMsg(Msg msg) {
    return msg.type
        ? Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              msg.content,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
            ),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: msg.content,
              placeholder: (context, val) => Container(
                color: Colors.white,
                child: Center(child: CircularProgressIndicator()),
                height: 150,
                width: 150,
              ),
              errorWidget: (context, val, obj) => Container(
                color: Colors.white,
                child: Icon(Icons.error),
                height: 50,
                width: 50,
              ),
            ),
          );
  }
}
