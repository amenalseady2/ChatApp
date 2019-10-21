import 'package:chat_app/core/blocs/user_bloc.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/core/repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterBloc {
  final _repository = Repository();

  GoogleSignInAccount googleAccount;
  final GoogleSignIn _googleSignIn = new GoogleSignIn();
  final FacebookLogin _facebookLogin = FacebookLogin();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User user = User.empty();
  FirebaseUser firebaseUser;
  String userToken;

  emailPasswordLogin(String email, String password) async {
    try {
      AuthResult result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      firebaseUser = user;
      userBloc.updateToken(user, userToken);
      print('login ${result.toString()}');
      return true;
    } catch (e) {
      print('errorss $e');
      return false;
    }
  }

  emailPasswordSignUp(String email, String password, String name) async {
    try {
      AuthResult result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      await updateUser(user, name);
      print('sign up ${result.toString()}');
      return true;
    } catch (e) {
      print('errorss $e');
      return false;
    }
  }

  googleRegister() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;
      await updateUser(user, googleUser.displayName);
      print("google signed in " + user.displayName);
      return true;
    } catch (e) {
      print('errorss s $e');
      return false;
    }
  }

  facebookRegister() async {
    try {
      final result = await _facebookLogin.logIn(['email']);

      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          String token = result.accessToken.token;
          final AuthCredential credential = FacebookAuthProvider.getCredential(
            accessToken: token,
          );
          final FirebaseUser user =
              (await _auth.signInWithCredential(credential)).user;
          await updateUser(user, user.displayName);
          print("facebook signed in " + user.displayName);
          return true;
          break;
        case FacebookLoginStatus.cancelledByUser:
          return false;
          break;
        case FacebookLoginStatus.error:
          return false;
          break;
      }
    } catch (e) {
      print('errorss s $e');
      return false;
    }
  }

  updateUser(FirebaseUser user, String name) async {
    final QuerySnapshot result = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: user.uid)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    if (documents.length == 0)
      await Firestore.instance.collection('users').document(user.uid).setData({
        'email': user.email,
        'name': name,
        'id': user.uid,
        'token': userToken,
        'photo_url':
            'https://firebasestorage.googleapis.com/v0/b/chat-app-368e8.appspot.com/o/avatar_icon_star_wars.jpg?alt=media&token=5725b940-8920-41b0-a898-18cd7f62de6d'
      });
    else
      await Firestore.instance
          .collection('users')
          .document(user.uid)
          .updateData({
        'token': userToken,
      });
    firebaseUser = user;
    return true;
  }

  getUser(FirebaseUser user) async {
    DocumentSnapshot snapshot =
        await Firestore.instance.collection('users').document(user.uid).get();
    this.user = User(snapshot);
  }
}

final registerBloc = RegisterBloc();
