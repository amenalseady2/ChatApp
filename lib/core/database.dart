import 'dart:io';

import 'package:chat_app/core/models/chat_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

import 'models/msg_model.dart';

final String tableChats = 'chats';
final String columnChatID = 'id';
final String columnLastModified = 'last_modified';

final String tableMsgs = 'msgs';
final String columnMsgID = 'msg_id';
final String columnTime = 'time';
final String columnContent = 'content';
final String columnType = 'type';
final String columnSenderID = 'sender_id';

final String columnParentChatID = 'id';

final String tableUsers = 'users';
final String columnUserID = 'user_id';

class DatabaseHelper {
  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 1;

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
              CREATE TABLE $tableChats (
                $columnChatID INTEGER TEXT KEY,
                $columnLastModified TEXT NOT NULL
              )
              ''');

    await db.execute('''
              CREATE TABLE $tableMsgs (
                $columnMsgID INTEGER TEXT KEY,
                $columnParentChatID INTEGER TEXT KEY,
                $columnTime TEXT,
                $columnContent TEXT,
                $columnType TEXT,
                $columnSenderID TEXT
              )
              ''');

    await db.execute('''
              CREATE TABLE $tableUsers (
                $columnUserID INTEGER TEXT KEY,
                $columnParentChatID INTEGER TEXT KEY
              )
              ''');
  }

  Future<int> insertChat(Chat chat) async {
    await deleteChat(chat.id);
    Database db = await database;
    int id = await db.insert(tableChats, chat.toDBJson());
    await insertMessages(chat.messages, chat.id);
    await insertUsers(chat.users, chat.id);
    return id;
  }

  insertMessages(List<Msg> messages, String chatID) async {
    Database db = await database;
    messages.forEach((m) {
      Map<String, dynamic> map = m.toJson();
      map.addAll({columnParentChatID: chatID});
      db.insert(tableMsgs, map);
    });
  }

  Future<int> insertMsg(Msg msg, String chatID) async {
    print('insertMsg ${msg.id} ${msg.content}');
    Database db = await database;
    await db.delete(tableMsgs, where: '$columnMsgID = ?', whereArgs: [msg.id]);
    Map<String, dynamic> map = msg.toJson();
    map.addAll({columnParentChatID: chatID});
    int id = await db.insert(tableMsgs, map);
    return id;
  }

  insertUsers(List<dynamic> users, String chatID) async {
    Database db = await database;
    users.forEach((u) {
      Map<String, dynamic> map = {columnUserID: u, columnParentChatID: chatID};
      db.insert(tableUsers, map);
    });
  }

  deleteChat(String chatID) async {
    Database db = await database;
    await db
        .delete(tableChats, where: '$columnChatID = ?', whereArgs: [chatID]);
    await db.delete(tableMsgs, where: '$columnChatID = ?', whereArgs: [chatID]);
    await db
        .delete(tableUsers, where: '$columnChatID = ?', whereArgs: [chatID]);
    return true;
  }

  Future<int> deleteMsg(String msgID) async {
    Database db = await database;
    int id = await db
        .delete(tableMsgs, where: '$columnMsgID = ?', whereArgs: [msgID]);
    return id;
  }

  Future<Chat> readChat(String chatID) async {
    Database db = await database;
    List<Map> map = await db
        .query(tableChats, where: '$columnChatID = ?', whereArgs: [chatID]);
    Chat chat;
    if (map.length != 0) {
      List<Msg> messages = await readMessages(chatID);
      List<dynamic> users = await readUsers(chatID);
      chat = Chat.fromDBJson(map.first);
      messages.sort((m1, m2) {
//        d1 = DateTime.fromMillisecondsSinceEpoch(m1);
        return m2.time.compareTo(m1.time);
      });
      chat.messages = messages;
      chat.users = users;
    }
    return chat;
  }

  readMessages(String chatID) async {
    Database db = await database;
    List<Map> map = await db.query(tableMsgs,
        where: '$columnParentChatID = ?', whereArgs: [chatID]);
    List<Msg> messages = new List();
    if (map.length != 0) {
      map.forEach((m) {
//        print('readMessages ${m}');
        messages.add(Msg.fromJson(m));
      });
    }
    return messages;
  }

  readUsers(String chatID) async {
    Database db = await database;
    List<Map> map = await db.query(tableUsers,
        where: '$columnParentChatID = ?', whereArgs: [chatID]);
    List<dynamic> users = new List();
    if (map.length != 0) {
      map.forEach((m) {
        users.add(m[columnUserID]);
      });
    }
    return users;
  }
}
