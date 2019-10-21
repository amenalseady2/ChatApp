import 'package:chat_app/ui/edit_profile_page.dart';
import 'package:chat_app/ui/tabs/chats_tab.dart';
import 'package:chat_app/ui/tabs/people_tab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Home'),
            actions: <Widget>[
              menu(),
            ],
            bottom: TabBar(
              tabs: [
                Tab(text: 'Chats'),
                Tab(text: 'People'),
              ],
              indicatorColor: Colors.deepOrange,
            ),
          ),
          body: TabBarView(children: [
            Center(
              child: ChatsTab(),
            ),
            Center(
              child: PeopleTab(),
            ),
          ]),
        ));
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e);
    }
  }

  Widget menu() {
    return PopupMenuButton<int>(
      padding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (value) {
        switch (value) {
          case 1:
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => EditProfilePage()));
            break;
          case 2:
            break;
          case 3:
            _logout();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: Row(
            children: <Widget>[
              IconButton(icon: Icon(Icons.account_circle), onPressed: null),
              Expanded(child: Text("Profile"))
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: <Widget>[
              IconButton(icon: Icon(Icons.settings), onPressed: null),
              Expanded(child: Text("Settings"))
            ],
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: Row(
            children: <Widget>[
              IconButton(icon: Icon(Icons.exit_to_app), onPressed: null),
              Expanded(child: Text("Logout"))
            ],
          ),
        ),
      ],
    );
  }
}
