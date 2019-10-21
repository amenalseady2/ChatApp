import 'package:chat_app/core/blocs/chat_bloc.dart';
import 'package:chat_app/core/blocs/user_bloc.dart';
import 'package:chat_app/core/models/chat_model.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ChatInput extends StatefulWidget {
  final Chat chat;
  final User user;

  const ChatInput({Key key, this.chat, this.user}) : super(key: key);

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput>
    with SingleTickerProviderStateMixin {
  bool isShowEmoji = false;

  final FocusNode _focusNode = new FocusNode();

  TextEditingController _controller = new TextEditingController();

  AnimationController controller;
  Animation<Offset> offset;

  AnimationController animationController;
  Animation<double> animation;

  void onFocusChange() {
    if (_focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowEmoji = false;
      });
    }
  }

  @override
  void initState() {
    _focusNode.addListener(onFocusChange);
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    )..addListener(() => setState(() {}));
    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.bounceInOut,
    );
    animationController.forward();

//    controller =
//        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
//    offset = Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset(0.0, 0.0))
//        .animate(controller);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(4),
          child: Row(
            children: <Widget>[
              Expanded(
//            child: SlideTransition(
//              position: offset,
                child: Card(
                  clipBehavior: Clip.hardEdge,
                  color: Colors.white,
                  elevation: 2,
                  margin: EdgeInsets.all(4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.insert_emoticon,
                          color: Colors.grey,
                        ),
                        onPressed: () {
//                          _focusNode.unfocus();
//                          setState(() {
//                            isShowEmoji = !isShowEmoji;
//                          });
                          selectEmoji();
                        },
                      ),
                      Expanded(
                        child: TextField(
                          focusNode: _focusNode,
                          controller: _controller,
                          maxLines: 3,
                          minLines: 1,
                          decoration: InputDecoration(
                            hintText: 'Type a message',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.attach_file,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          sendPic();
                        },
                      ),
                    ],
                  ),
                ),
              ),
//          ),
              ScaleTransition(
                scale: animation,
                child: Card(
                  clipBehavior: Clip.hardEdge,
                  color: Colors.blue,
                  margin: EdgeInsets.all(4),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      sendText();
//                    switch (controller.status) {
//                      case AnimationStatus.completed:
//                        controller.reverse();
//                        break;
//                      case AnimationStatus.dismissed:
//                        controller.forward();
//                        break;
//                      default:
//                    }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Visibility(
          child: Container(
            child: EmojiPicker(
              rows: 3,
              columns: 7,
              buttonMode: ButtonMode.MATERIAL,
              selectedCategory: Category.SMILEYS,
              onEmojiSelected: (emoji, category) {
                print('emoji cat ${category.toString()}');
                if (_controller.text == null)
                  _controller.text = emoji.emoji;
                else
                  _controller.text += emoji.emoji;
              },
            ),
          ),
          visible: isShowEmoji,
        ),
      ],
    );
  }

  selectEmoji() async {
    _focusNode.unfocus();
    await Future.delayed(Duration(milliseconds: 200)).then((d) {});
    setState(() {
      isShowEmoji = !isShowEmoji;
    });
  }

  void sendText() async {
    if (_controller.text != null &&
        _controller.text.trim().isNotEmpty &&
        _controller.text.trim() != ' ') {
      bounce();
      chatBloc.sendText(
          _controller.text.trim(), widget.chat.id, userBloc.firebaseUser.uid);
      _controller.clear();
    }
  }

  void sendPic() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(
        progressWidget: Center(child: CircularProgressIndicator()),
        message: 'Uploading...',
        borderRadius: 8);
    pr.show();
    await chatBloc.sendPic(image, widget.chat.id, userBloc.firebaseUser.uid);
    pr.dismiss();
    bounce();
    _controller.clear();
  }

  void bounce() async {
    animationController.reverse().then((v) {
      animationController.forward();
    });
  }
}
