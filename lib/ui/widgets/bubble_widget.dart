import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/core/blocs/chat_bloc.dart';
import 'package:chat_app/core/blocs/user_bloc.dart';
import 'package:chat_app/core/models/msg_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BubbleWidget extends StatefulWidget {
  final String chatID;
  final Msg msg;
  final BuildContext context;

  const BubbleWidget({Key key, this.msg, this.context, this.chatID})
      : super(key: key);

  @override
  _BubbleWidgetState createState() => _BubbleWidgetState();
}

class _BubbleWidgetState extends State<BubbleWidget>
    with TickerProviderStateMixin {
  var alignment = Alignment.center;
  var crossAxisAlignment = CrossAxisAlignment.center;
  var color = Colors.white;
  var nip = BubbleNip.no;
  double left = 0, right = 0;
  bool isToDelete = false, showInfo = false;

  AnimationController _controller;

  @override
  void initState() {
    if (widget.msg.senderID != null) if (widget.msg.senderID ==
        userBloc.firebaseUser.uid) {
      color = Colors.blueAccent;
      alignment = Alignment.centerRight;
      crossAxisAlignment = CrossAxisAlignment.end;
      left = MediaQuery.of(widget.context).size.width / 3;
    } else {
      color = Colors.deepOrangeAccent;
      alignment = Alignment.centerLeft;
      crossAxisAlignment = CrossAxisAlignment.start;
      right = MediaQuery.of(widget.context).size.width / 3;
    }
    if (!widget.msg.type) color = Colors.transparent;

    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: <Widget>[
          Visibility(
            visible: isToDelete,
            child: ScaleTransition(
              scale: new CurvedAnimation(
                parent: _controller,
                curve: new Interval(0.0, 1.0, curve: Curves.easeOut),
              ),
              child: new FloatingActionButton(
                heroTag: null,
                backgroundColor: Colors.red,
                mini: true,
                child: new Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  chatBloc.deleteMsg(widget.chatID, widget.msg.id);
                  setState(() {
                    isToDelete = !isToDelete;
                  });
                },
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                showInfo = !showInfo;
              });
              if (_controller.isDismissed) {
                _controller.forward();
              } else {
                _controller.reverse();
              }
            },
            onLongPress: () {
              if (widget.msg.senderID == userBloc.firebaseUser.uid) {
                setState(() {
                  isToDelete = !isToDelete;
                });
                if (_controller.isDismissed) {
                  _controller.forward();
                } else {
                  _controller.reverse();
                }
              }
            },
            child: Bubble(
              color: color,
              child: buildMsg(widget.msg),
              elevation: 0,
              margin: BubbleEdges.only(top: 5, left: left, right: right),
              alignment: alignment,
              nip: nip,
              nipRadius: 2,
              padding: BubbleEdges.all(0),
              radius: Radius.circular(16),
            ),
          ),
          Visibility(
            visible: showInfo,
            child: Padding(
              padding: EdgeInsets.only(top: 4, left: 8, right: 8),
              child: Text(
                '${DateFormat('hh:mm a').format(new DateTime.fromMillisecondsSinceEpoch(widget.msg.time.toDate().millisecondsSinceEpoch))}',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
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
