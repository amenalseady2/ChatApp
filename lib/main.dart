import 'package:chat_app/core/blocs/register_bloc.dart';
import 'package:chat_app/core/blocs/user_bloc.dart';
import 'package:chat_app/ui/home_page.dart';
import 'package:chat_app/ui/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  String token;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

//  static const AndroidNotificationChannel channel =
//      const AndroidNotificationChannel(
//          id: 'default_notification',
//          name: 'Default',
//          description: 'Grant this app the ability to show notifications',
//          importance: AndroidNotificationChannelImportance.HIGH);

//  fun() async {
//    await LocalNotifications.createAndroidNotificationChannel(channel: channel);
//  }

  Future onSelectNotification(String payload) {
//    debugPrint("payload : $payload");
//    showDialog(
//      context: context,
//      builder: (_) => new AlertDialog(
//        title: new Text('Notification'),
//        content: new Text('$payload'),
//      ),
//    );
  }

  @override
  void initState() {
//    fun();

    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);

    super.initState();
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.getToken().then((token) {
      print('token $token');
      this.token = token;
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("msg onMessage: $message");
//        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//            'default_notification', 'Default', 'your channel description',
//            icon: '@mipmap/ic_launcher',
//            importance: Importance.Max,
//            priority: Priority.High,
//            ticker: 'ticker');
//        var iOSPlatformChannelSpecifics = IOSNotificationDetails();
//        var platformChannelSpecifics = NotificationDetails(
//            androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
//
//        await flutterLocalNotificationsPlugin.show(
//            0,
//            message['notification']['title'],
//            message['notification']['body'],
//            platformChannelSpecifics,
//            payload: message['data']);

        var android = new AndroidNotificationDetails(
            'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
            priority: Priority.High,
            importance: Importance.Max);
        var iOS = new IOSNotificationDetails();
        var platform = new NotificationDetails(android, iOS);
        await flutterLocalNotificationsPlugin.show(
            0,
            message['notification']['title'],
            message['notification']['body'],
            platform,
            payload: 'dataaaa');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          FirebaseUser user = snapshot.data;
          if (user == null) {
            return RegisterPage();
          }
          registerBloc.firebaseUser = user;
          registerBloc.userToken = token;
          userBloc.firebaseUser = user;
          userBloc.updateToken(user, token);
          return HomePage();
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
