import 'package:chat_app/core/blocs/register_bloc.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:toast/toast.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  double _radius = 80;

  String email = '', password = '', name = '';
  bool _obscureText = true;
  bool _loginState = false;

  void changeLoginState(bool value) => setState(() {
        _loginState = value;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_loginState ? 'Sign Up' : 'Login')),
      body: body(),
    );
  }

  Widget body() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blueAccent, Colors.deepOrangeAccent],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Card(
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: FlatButton(
                            padding: EdgeInsets.all(8),
                            color: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(80)),
                            textColor: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Icon(FontAwesomeIcons.facebookF),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text('Facebook',
                                      textAlign: TextAlign.center),
                                ),
                              ],
                            ),
                            onPressed: () {
                              facebookRegister();
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('/'),
                        ),
                        Expanded(
                          child: FlatButton(
                            padding: EdgeInsets.all(8),
                            color: Colors.deepOrange,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(80)),
                            textColor: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Icon(FontAwesomeIcons.google),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text('Google',
                                      textAlign: TextAlign.center),
                                ),
                              ],
                            ),
                            onPressed: () {
                              googleRegister();
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(child: Divider()),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Text(
                            "OR",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    SwitchListTile(
                      value: _loginState,
                      activeColor: Colors.deepOrange,
                      activeTrackColor: Colors.deepOrange[300],
                      inactiveThumbColor: Colors.blue,
                      inactiveTrackColor: Colors.blue[300],
                      onChanged: changeLoginState,
                      title: new Text('Sign Up or Login?',
                          style: new TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(padding: EdgeInsets.only(top: 24)),
                    Visibility(
                      visible: _loginState,
                      child: TextFormField(
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.account_circle),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(_radius)),
                            labelText: 'Name'),
                        validator: (String value) {
                          if (value.isEmpty)
                            return 'Please enter name';
                          else if (value.length < 4)
                            return 'Name must be at least 4 characters';
                          return null;
                        },
                        onSaved: (String value) {
                          setState(() {
                            name = value;
                          });
                        },
                      ),
                    ),
                    Visibility(
                      visible: _loginState,
                      child: Padding(padding: EdgeInsets.only(top: 16)),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(_radius)),
                          labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (String value) {
                        if (value.isEmpty)
                          return 'Please enter email';
                        else if (!EmailValidator.validate(value, true))
                          return 'Please enter valid email';
                        return null;
                      },
                      onSaved: (String value) {
                        setState(() {
                          email = value;
                        });
                      },
                    ),
                    Padding(padding: EdgeInsets.only(top: 16)),
                    TextFormField(
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                              icon: Icon(
                                Icons.remove_red_eye,
                                color: _obscureText
                                    ? Colors.grey
                                    : Theme.of(context).accentColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              }),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(_radius)),
                          labelText: 'Password'),
                      validator: (String value) {
                        if (value.isEmpty)
                          return 'Please enter password';
                        else if (value.length < 6)
                          return 'Password must be at least 6 characters';
                        return null;
                      },
                      onSaved: (String value) {
                        setState(() {
                          password = value;
                        });
                      },
                    ),
                    Padding(padding: EdgeInsets.only(top: 24)),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(_radius)),
                      child: FlatButton(
                        padding: EdgeInsets.all(16),
                        color: _loginState ? Colors.deepOrange : Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(_radius)),
//                textColor: Colors.white,
                        child: Text(
                          _loginState ? 'Sign Up' : 'Login',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        onPressed: () {
                          _loginState ? _signUp() : _login();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _validate() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      return true;
    }
    return false;
  }

  _signUp() async {
    if (_validate()) {
      ProgressDialog pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal,
          isDismissible: false,
          showLogs: false);
      pr.style(
          progressWidget: Center(child: CircularProgressIndicator()),
          message: 'Creating your account...',
          borderRadius: 8);
      pr.show();

      bool res = await registerBloc.emailPasswordSignUp(email, password, name);
      pr.dismiss();
      if (!res)
        Toast.show('Something went wrong', context,
            backgroundColor: Theme.of(context).accentColor,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.CENTER,
            textColor: Colors.black,
            backgroundRadius: 80);
    }
  }

  _login() async {
    if (_validate()) {
      ProgressDialog pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal,
          isDismissible: false,
          showLogs: false);
      pr.style(
          progressWidget: Center(child: CircularProgressIndicator()),
          message: 'Loging in...',
          borderRadius: 8);
      pr.show();

      bool res = await registerBloc.emailPasswordLogin(email, password);
      pr.dismiss();
      if (!res)
        Toast.show('User data not found!', context,
            backgroundColor: Theme.of(context).accentColor,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.CENTER,
            textColor: Colors.black,
            backgroundRadius: 80);
    }
  }

  void googleRegister() async {
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(
        progressWidget: Center(child: CircularProgressIndicator()),
        message: 'Loging in...',
        borderRadius: 8);
    pr.show();

    bool res = await registerBloc.googleRegister();
    pr.dismiss();
    if (!res)
      Toast.show('User data not found!', context,
          backgroundColor: Theme.of(context).accentColor,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
          textColor: Colors.black,
          backgroundRadius: 80);
  }

  void facebookRegister() async {
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(
        progressWidget: Center(child: CircularProgressIndicator()),
        message: 'Loging in...',
        borderRadius: 8);
    pr.show();

    bool res = await registerBloc.facebookRegister();
    pr.dismiss();
    if (!res)
      Toast.show('User data not found!', context,
          backgroundColor: Theme.of(context).accentColor,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
          textColor: Colors.black,
          backgroundRadius: 80);
  }
}
