import 'dart:async';
import 'package:flutter/material.dart';
import 'package:where_is_my_ride/auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
//import 'package:simple_permissions/simple_permissions.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key, required this.title, required this.auth}) : super(key: key);

  final String title;
  final BaseAuth auth;

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late SharedPreferences prefs;
  static final formKey = new GlobalKey<FormState>();
  final _user = TextEditingController();
  final _password = TextEditingController();
  bool loading = false;
  var enableSynthesizer = false;
  var ttsPlaying = false;
  FlutterTts flutterTts = new FlutterTts();
  String error = "";

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit(context) async {
    if (validateAndSave()) {
      setState(() => this.error = "Loading...");
      String userId = await widget.auth.signIn(_user.text, _password.text);
      if(userId != 'Error') {
        Navigator.of(context).pushReplacementNamed('/home');
      }
      else {
        widget.auth.getError().then((error) {
          print(error);
          setState(() => this.error = error);
          this.showError();
          if(enableSynthesizer && !ttsPlaying) {
            setState(() => ttsPlaying = true);
            flutterTts.speak(error).then((result) {
              if (result == 1) setState(() => ttsPlaying = false);
            });
          }
        });
      }
    }
    setState(() => this.loading = false);
  }

  Future<Null> showError() async {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return new SimpleDialog(
          title: Text(
            '$error',
            style: new TextStyle(fontSize: 12.0)
          ),
          children: <Widget>[
            new SimpleDialogOption(
              onPressed: () { launch("tel://905-529-1717"); },
              child: const Text('call DARTS'),
            ),
            new SimpleDialogOption(
              onPressed: () { Navigator.pop(context); },
              child: const Text('Close'),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Row(
          children: <Widget>[
            new Padding(padding: EdgeInsets.symmetric(vertical: 9.0),child: new Image(image: AssetImage("images/logo.png"))),
            new Padding(padding: EdgeInsets.only(left: 20.0),child: new Text(widget.title))
          ],
        )
      ),
      body: new ListView(
        children: [
        new Image(
          image: AssetImage("images/main.jpg"),
          width: MediaQuery.of(context).viewInsets.bottom == 0 ? null : 0.0,
        ),
        new Padding ( padding: new EdgeInsets.all(20.0), child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding( padding: const EdgeInsets.only(bottom: 0.0), child: new Text(
              "Let's find your ride...",
              textAlign: TextAlign.left,
              style: new TextStyle(fontSize: 26.0, color: Color.fromRGBO(51, 13, 112, 1.0), fontWeight: FontWeight.w300),
            )),
            new Theme(
              data: new ThemeData(
                primaryColor: Color.fromRGBO(74, 74, 74, 1.0),
                // accentColor: Color.fromRGBO(74, 74, 74, 1.0),
                hintColor: Color.fromRGBO(74, 74, 74, 1.0)
              ),
              child: new TextFormField(
              controller: _user,
              decoration: new InputDecoration(
                labelText: 'Passenger ID#',
                labelStyle: new TextStyle(color: Color.fromRGBO(74, 74, 74, 1.0), fontSize: 16.0)
              ),
              style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Passenger ID can not be empty.';
                }
              },
            )),
            new Theme(
              data: new ThemeData(
                primaryColor: Color.fromRGBO(74, 74, 74, 1.0),
                // accentColor: Color.fromRGBO(74, 74, 74, 1.0),
                hintColor: Color.fromRGBO(74, 74, 74, 1.0)
              ),
              child: new TextFormField(
              controller: _password,
              decoration: new InputDecoration(
                labelText: 'Password',
                labelStyle: new TextStyle(color: Color.fromRGBO(74, 74, 74, 1.0), fontSize: 16.0)
              ),
              obscureText: true,
              style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Password can not be empty.';
                }
              },
            )),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: MaterialButton(
                height: 40.0,
                minWidth: 2000.0,
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                onPressed: () {
                  // Validate will return true if the form is valid, or false if
                  // the form is invalid.
                  if (formKey.currentState!.validate() && !loading) {
                    validateAndSubmit(context);
                    setState(() => this.loading = true);
                  }
                },
                child: Text(loading ? "Loading..." : "Find My Ride"),
              ),
            ),
            new Container(
              color: Color.fromRGBO(242, 242, 242, 1.0),
              child: new Padding(padding: EdgeInsets.all(20.0), child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Padding(padding: EdgeInsets.only(right: 10.0), child: new Icon(
                    Icons.error_outline,
                    color: Color.fromRGBO(237, 61, 0, 1.0),
                    size: 30.0,
                  )),
                  new Expanded(
                  child: new RichText(
                    text: new TextSpan(
                      style: new TextStyle(
                        fontSize: 14.0,
                        color: Color.fromRGBO(74, 74, 74, 1.0)
                      ),
                      children: [
                        new TextSpan (
                          text: "Please Note",
                          style: new TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(237, 61, 0, 1.0)),
                        ),
                        new TextSpan (
                          text: " Ride information is only available within 30 minutes of your scheduled pick-up time.",
                        )
                      ]
                    ),
                  )),
                ],
              ))
            ),
          ],
        ),
      ))]),
    );
  }
  @override
  void initState() {
    super.initState();
    widget.auth.currentUserID().then((response){
      if(response != null) {
        _user.text = response;
      }
    });
    /*Permission permission = Permission.AccessFineLocation;
    SimplePermissions.checkPermission(permission).then((response) {
      if(!response) {
        SimplePermissions.requestPermission(permission);
      }
    });*/
     SharedPreferences.getInstance().then((response){
      prefs = response;
      var enableSynthesizerVal = prefs.getBool("enableSynthesizer") ?? false;
      setState(() {
        enableSynthesizer = enableSynthesizerVal;
      });
    });
  }
}
