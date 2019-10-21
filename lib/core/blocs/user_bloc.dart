import 'package:chat_app/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserBloc {
  FirebaseUser firebaseUser;
  User user = User.empty();
  String userToken;

  updateUser(User user, String name, image) async {
    if (image != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child('profile-pics/${user.id}')
          .putFile(image);
      StorageTaskSnapshot snapshot = await task.onComplete;
      String url = await snapshot.ref.getDownloadURL();
      await Firestore.instance
          .collection('users')
          .document(user.id)
          .updateData({'photo_url': url, 'name': name});
    } else {
      await Firestore.instance
          .collection('users')
          .document(user.id)
          .updateData({'name': name});
    }
    return true;
  }

  updateToken(FirebaseUser user, String token) async {
    print('update token $token ${user.uid}');
    await Firestore.instance.collection('users').document(user.uid).updateData({
      'token': token,
    });
    return true;
  }
}

final userBloc = UserBloc();
