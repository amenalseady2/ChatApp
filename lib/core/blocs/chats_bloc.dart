import 'package:cloud_firestore/cloud_firestore.dart';

class ChatsBloc {
  startConversation(List<String> ids) async {
    DocumentSnapshot snapshot = await searchConversations(ids);
    if (snapshot != null)
      return snapshot;
    else
      return await createConversation(ids);
  }

  searchConversations(List<String> ids) async {
    print('ids ${ids.length}');
    QuerySnapshot snapshot =
        await Firestore.instance.collection('conversations').getDocuments();

    List<DocumentSnapshot> snapshots = snapshot.documents.where((d) {
      print('document ${d.documentID}');
      List<dynamic> users = d.data['users'];
      print('users list ${users.toString()}');
      int counter = 0;
      if (users != null && users.length == ids.length)
        ids.forEach((i) {
          print('iii $i');
          if (users.contains(i)) counter++;
        });
      print('counter $counter');
      if (counter == ids.length)
        return true;
      else
        return false;
    }).toList();
    print('snapshot ${snapshots.length}');
    if (snapshots.length > 0)
      return snapshots.first;
    else
      return null;
  }

  createConversation(List<String> ids) async {
    DocumentReference reference =
        Firestore.instance.collection('conversations').document();
    await reference.setData({'users': ids, 'last_modified': DateTime.now()});
    print('new document ${reference.documentID}');
    await reference
        .collection('messages')
        .document()
        .setData({'time': DateTime.now(), 'content': 'Welcome', 'type': true});
    return reference.snapshots().first;
  }
}

final chatsBloc = ChatsBloc();
