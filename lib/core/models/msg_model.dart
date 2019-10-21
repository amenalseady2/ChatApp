import 'package:cloud_firestore/cloud_firestore.dart';

class Msg {
  String content;
  Timestamp time;
  String senderID;
  String id;
  bool type;

  Msg(DocumentSnapshot snapshot) {
    content = snapshot['content'];
    time = snapshot['time'];
    senderID = snapshot['sender_id'];
    id = snapshot.documentID;
    type = snapshot['type'];
  }

  Map<String, dynamic> toJson() {
    print('toJson ${this.content} ${this.time}');
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['msg_id'] = this.id;
    data['content'] = this.content;
    data['time'] = this.time.millisecondsSinceEpoch.toString();
    data['type'] = this.type.toString();
    data['sender_id'] = this.senderID;
    return data;
  }

  Msg.fromJson(Map<String, dynamic> json) {
    id = json['msg_id'];
    content = json['content'];
    time = Timestamp.fromMillisecondsSinceEpoch(int.parse(json['time']));
    type = json['type'] == 'true';
    senderID = json['sender_id'];
  }
}
