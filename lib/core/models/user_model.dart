import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String email;
  String id;
  String name;
  String photoUrl;

  User(DocumentSnapshot snapshot) {
    email = snapshot['email'];
    name = snapshot['name'];
    photoUrl = snapshot['photo_url'];
    id = snapshot['id'];
  }
  
  User.empty();
}
