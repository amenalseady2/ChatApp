import 'dart:convert';
import 'dart:io';

import 'package:chat_app/core/models/chat_model.dart';
import 'package:chat_app/core/models/msg_model.dart';
import 'package:chat_app/core/repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatBloc {
  final _repository = Repository();
  final _chatFetcher = PublishSubject<Chat>();

  Observable<Chat> get chatList => _chatFetcher.stream;

  Chat chat = Chat.empty();

  Future<Chat> readChatDB(String documentID) async {
    Chat chat = await _repository.readChat(documentID);
    if (chat != null) print('readChatDB ${chat.id} ${chat.messages.length}');
    return chat;
  }

  saveChatDB(Chat chat) async {
    int id = await _repository.insertChat(chat);
    print('saveChatDB $id');
  }

  getStored(String documentID) async {
    Chat chat = await readChat(documentID);
    if (chat == null) return null;
    print('chat stored ${chat.messages.length}');
    return chat;
  }

  getChat(String documentID) async {
//    Chat chat = await getStored(documentID);
    chat = await readChatDB(documentID);

    if (chat != null) {
      _chatFetcher.sink.add(chat);
//      saveChatDB(chat);
      var query = Firestore.instance
          .collection('conversations')
          .document(documentID)
          .collection('messages')
//          .where('time', isGreaterThan: chat.lastModified)
          .orderBy('time', descending: false);

      checkForUpdates(query, documentID);
    } else {
      Firestore instance = Firestore.instance;
      DocumentSnapshot chatSnapshot =
          await instance.collection('conversations').document(documentID).get();

      await chatSnapshot.reference
          .collection('messages')
          .orderBy('time', descending: true)
          .getDocuments(source: Source.cache)
          .then((snapshot) {
        print('length ${snapshot.documents.length}');
        chat = Chat(chatSnapshot, snapshot);
        print('length chat ${chat.messages.length}');

//        saveChat(chat);
        _chatFetcher.sink.add(chat);
      });
      await saveChatDB(chat);
      var query = chatSnapshot.reference
          .collection('messages')
          .orderBy('time', descending: false);
      checkForUpdates(query, documentID);
    }
  }

  checkForUpdates(query, String id) async {
    chat = await readChatDB(id);
    if (chat == null) {
      chat = Chat.empty();
      chat.messages = new List();
    }
    query.snapshots().listen((querySnapShot) {
      querySnapShot.documentChanges.forEach((documentChange) {
        if (documentChange.type == DocumentChangeType.added) {
          print("documentss: ${documentChange.document.data} added");
          Msg msg = new Msg(documentChange.document);
          List<Msg> msgss = new List();

          chat.messages.forEach((m) {
//            print('checkupdates old ${m.id} new ${msg.id}');
            if (m.id == msg.id) msgss.add(msg);
          });
          if (msgss.length == 0) {
            print('msg added ${msgss.length}');
            chat.messages.insert(0, msg);
//            saveChatDB(chat);
            _repository.insertMsg(msg, id);
            _chatFetcher.sink.add(chat);
          }
        } else if (documentChange.type == DocumentChangeType.modified) {
          print("documentss: ${documentChange.document.data} modified");
        } else if (documentChange.type == DocumentChangeType.removed) {
          print("documentss: ${documentChange.document.data} removed");
          Msg msg = new Msg(documentChange.document);
          List<Msg> msgss = new List();
          chat.messages.forEach((m) {
            if (m.id == msg.id) msgss.add(m);
          });
          print('messages ${chat.messages.length}');
          msgss.forEach((m) => chat.messages.remove(m));
          print('messages ${chat.messages.length}');
//          saveChat(chat);
          _repository.deleteMsg(msg.id);
          _chatFetcher.sink.add(chat);
//          getChat(id);
//          dddd(msg, id);
        }
      });
    });
  }

  dddd(Msg msg, String chatID) async {
    await _repository.deleteMsg(msg.id);
    getChat(chatID);
  }

  saveChat(Chat chat) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    print('json encode ${jsonEncode(chat.toJson())}');
    await _prefs.setString('chat_${chat.id}', jsonEncode(chat.toJson()));
//    readChat(chat.id);
  }

  Future<Chat> readChat(String id) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    print('json keys ${_prefs.getKeys()}');
    print('$id json decode ${_prefs.getString('chat_$id')}');
    if (_prefs.getString('chat_$id') == null) return null;
    Chat chat = Chat.fromJson(jsonDecode(_prefs.getString('chat_$id')));
    return chat;
  }

  saveLatest(Chat chat) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    int time = chat.lastModified.millisecondsSinceEpoch;
    print('setlatest $time');
    _prefs.setInt('latest_${chat.id}', time);
  }

  Future<Timestamp> getLatest(String id) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    int timestamp = _prefs.getInt('latest_$id');
    print('getlatest $timestamp');
    if (timestamp == null) return null;
    return new Timestamp.fromMillisecondsSinceEpoch(timestamp);
  }

  sendText(String txt, String chatID, String senderID) async {
    Timestamp time = Timestamp.now();
    await Firestore.instance
        .collection('conversations')
        .document(chatID)
        .collection('messages')
        .document()
        .setData({
      'time': time,
      'content': txt,
      'sender_id': senderID,
      'type': true
    });
    await Firestore.instance
        .collection('conversations')
        .document(chatID)
        .updateData({'last_modified': time});
    return true;
  }

  sendPic(File image, String chatID, String senderID) async {
    Timestamp time = Timestamp.now();
    StorageUploadTask task = FirebaseStorage.instance
        .ref()
        .child('pics/${time.toString()}-$senderID')
        .putFile(image);
    StorageTaskSnapshot snapshot = await task.onComplete;
    String url = await snapshot.ref.getDownloadURL();

    await Firestore.instance
        .collection('conversations')
        .document(chatID)
        .collection('messages')
        .document()
        .setData({
      'time': time,
      'content': url,
      'sender_id': senderID,
      'type': false
    });
    await Firestore.instance
        .collection('conversations')
        .document(chatID)
        .updateData({'last_modified': time});
    return true;
  }

  deleteMsg(String chatID, String msgID) async {
    await Firestore.instance
        .collection('conversations')
        .document(chatID)
        .collection('messages')
        .document(msgID)
        .delete();
  }

  dispose() {
    _chatFetcher.close();
  }
}

final chatBloc = ChatBloc();
