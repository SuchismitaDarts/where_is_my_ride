import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  LoadingPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _LoadingPageState createState() => new _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  
  @override
  Widget build(BuildContext context) {
    return  new Container(
      decoration: const BoxDecoration(
        image: const DecorationImage(
          fit: BoxFit.fill,
          image: const AssetImage("images/launch-screen.jpg"),
        ),
      )
    );
  }
  @override
  void initState() {
    super.initState();
  }
}