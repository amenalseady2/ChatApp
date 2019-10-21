import 'package:chat_app/core/models/msg_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  String id;
  List<dynamic> users;
  Timestamp lastModified;
  List<Msg> messages = new List();

  Chat(DocumentSnapshot snapshot, QuerySnapshot messages) {
    id = snapshot.documentID;
    users = snapshot['users'];
    lastModified = snapshot['last_modified'];
    messages.documents.forEach((m) {
      this.messages.add(new Msg(m));
    });
  }

  Chat.empty();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['last_modified'] = this.lastModified.millisecondsSinceEpoch.toString();
    if (this.users != null) {
      data['users'] = this.users;
    }
    if (this.messages != null) {
      data['messages'] = this.messages.map((v) => v.toJson()).toList();
    }
    return data;
  }

  Chat.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    lastModified =
        Timestamp.fromMillisecondsSinceEpoch(int.parse(json['last_modified']));
    if (json['users'] != null) {
      users = new List<dynamic>();
      json['users'].forEach((v) {
        users.add(v);
      });
    }
    if (json['messages'] != null) {
      messages = new List<Msg>();
      json['messages'].forEach((v) {
        messages.add(new Msg.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toDBJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['last_modified'] = this.lastModified.millisecondsSinceEpoch.toString();
    return data;
  }

  Chat.fromDBJson(Map<String, dynamic> json) {
    id = json['id'];
    lastModified =
        Timestamp.fromMillisecondsSinceEpoch(int.parse(json['last_modified']));
  }
}
