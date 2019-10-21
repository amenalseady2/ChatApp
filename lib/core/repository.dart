import 'package:chat_app/core/models/chat_model.dart';

import 'database.dart';
import 'models/msg_model.dart';

class Repository {
  final DatabaseHelper helper = DatabaseHelper.instance;

  Future<int> insertChat(Chat chat) => helper.insertChat(chat);

  Future<int> insertMsg(Msg msg, String chatID) =>
      helper.insertMsg(msg, chatID);

  Future<int> deleteMsg(String msgID) => helper.deleteMsg(msgID);

  Future<Chat> readChat(String chatID) => helper.readChat(chatID);
}
