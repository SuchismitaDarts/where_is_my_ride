import 'package:flutter/material.dart';
import 'package:where_is_my_ride/auth.dart';
import 'package:where_is_my_ride/login.dart';
import 'package:where_is_my_ride/map.dart';
import 'package:where_is_my_ride/loading.dart';

class RootPage extends StatefulWidget {
  RootPage({Key? key, required this.auth}) : super(key: key);
  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

enum AuthStatus {
  notSignedIn,
  signedIn,
  loading
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.notSignedIn;

  initState() {
    super.initState();
    AuthStatus authStatus = AuthStatus.notSignedIn;
    /*widget.auth.currentUser().then((userId) {
      setState(() {
        authStatus =
            userId != null ? AuthStatus.signedIn : AuthStatus.notSignedIn;
      });
    });*/
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return new LoginPage(title: 'Darts Login', auth: widget.auth);
        //return new LoadingPage(title: 'Loading...');
      case AuthStatus.signedIn:
        return new MapPage(title: 'Map Page', auth: widget.auth);
      case AuthStatus.loading:
        return new LoadingPage(title: 'Loading...');
      default:
        return new LoginPage(title: 'Darts Login', auth: widget.auth);
    }
  }
}
