import 'package:where_is_my_ride/auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuPage extends StatefulWidget {
  MenuPage({Key? key, required this.title, required this.auth}) : super(key: key);

  final String title;
  final BaseAuth auth;

  @override
  _MenuPageState createState() => new _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late SharedPreferences prefs;
  var showLocation = true;
  var enableSynthesizer = false;
  var id = "Loading...";

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Row(
          children: <Widget>[
            new Padding(padding: EdgeInsets.symmetric(vertical: 9.0),child: new Image(image: AssetImage("images/logo.png"))),
            new Padding(padding: EdgeInsets.only(left: 20.0),child: new Text(widget.title))
          ],
        ),
        /*actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],*/
      ),
      body: new SingleChildScrollView (child: new Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          new Container(
            decoration: const BoxDecoration(
              image: const DecorationImage(
                fit: BoxFit.fill,
                image: const AssetImage("images/menu-bg.jpg"),
              ),
            ),
            child: new Column(
              children: [
              new Padding(padding: const EdgeInsets.only(top: 25.0), child: new Container(
                width: 80.0,
                height: 80.0,
                decoration: new BoxDecoration(
                  color: Color.fromRGBO(237, 61, 0, 1.0),
                  borderRadius: new BorderRadius.only(
                    topLeft:  const  Radius.circular(50.0),
                    topRight: const  Radius.circular(50.0),
                    bottomLeft:  const  Radius.circular(50.0),
                    bottomRight: const  Radius.circular(50.0),
                    )),
                child: new Icon(
                  Icons.perm_identity,
                  color: Colors.white,
                  size: 48.0
                )
              )),
              new Padding(padding: EdgeInsets.only(top: 10.0), child: new Center(child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              new Text(
                "Passenger ID",
                style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
              )]))),
              new Center(child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              new Text(
                "#"+id,
                style: new TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(237, 61, 0, 1.0)),
              ),])),
              new Padding(padding: const EdgeInsets.only(bottom: 25.0, top: 7.0), child: new Container(height: 28.0, child: new OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  // outlineColor: Colors.white,
                  textStyle: TextStyle(color: Colors.white, fontSize: 13.0),
                ),
                onPressed: () {
                  widget.auth.signOut().then((onValue){
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/login');
                  });
                },
                child: Text("Change ..."),
              )
              ))])
          ),
           new Padding(padding: EdgeInsets.only(left: 20.0, right: 20.0),child: new Container(child: new Row(
            children: [
              new Icon(
                Icons.accessibility,
                color: Color.fromRGBO(237, 61, 0, 1.0)
              ),
              new Padding(padding: EdgeInsets.only(left:10.0), child: new Text (
                "Show My Current Location"
              )),
              new Expanded(
                child: new Align(alignment: Alignment.centerRight, child: new Checkbox(
                  value: showLocation,
                  activeColor: Theme.of(context).primaryColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (value) {
                    prefs.setBool("showLocation", value!);
                    setState(() {showLocation = value;});
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
                  ))
              ),
            ]
          ))),
          new Padding(padding: EdgeInsets.only(left: 20.0, right: 20.0),child: new Container(decoration: new BoxDecoration(border: const Border(
            top: const BorderSide(width: 1.0, color: Color.fromRGBO(232, 232, 232, 1.0)),
            )), child: new Row(
            children: [
              new Icon(
                Icons.hearing,
                color: Color.fromRGBO(237, 61, 0, 1.0)
              ),
              new Padding(padding: EdgeInsets.only(left:10.0), child: new Text (
                "Enable Speech Synthesizer"
              )),
              new Expanded(
                child: new Align(alignment: Alignment.centerRight, child: new Checkbox(
                  value: enableSynthesizer,
                  activeColor: Theme.of(context).primaryColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (value) {
                    prefs.setBool("enableSynthesizer", value!);
                    setState(() {enableSynthesizer = value;});
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
                  ))
              ),
            ]
          ))),
          new Padding(padding: EdgeInsets.only(left: 20.0, right: 20.0),child: new Container(decoration: new BoxDecoration(border: const Border(
            top: const BorderSide(width: 1.0, color: Color.fromRGBO(232, 232, 232, 1.0)),
            )), child: new Padding(padding: EdgeInsets.symmetric(vertical: 6.0), child: new Row (
            children: [
              new Icon(
                Icons.phone,
                color: Color.fromRGBO(237, 61, 0, 1.0)
              ),
              new Padding(padding: EdgeInsets.only(left:10.0), child: new Text (
                "Call DARTS",
                style: new TextStyle(fontWeight: FontWeight.bold)
              )),
              new Padding(padding: EdgeInsets.only(left:5.0), child: new InkWell ( 
                onTap: () {launch("tel:905-529-1717");},
                child: new Text (
                "905-529-1717",
                style: new TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              )))
            ]
          )))),
          new Padding(padding: EdgeInsets.only(left: 20.0, right: 20.0),child: new Container(decoration: new BoxDecoration(border: const Border(
          top: const BorderSide(width: 1.0, color: const Color.fromRGBO(232, 232, 232, 1.0)),
          bottom: const BorderSide(width: 1.0, color: const Color.fromRGBO(232, 232, 232, 1.0)),
          )), child: new Padding(padding: EdgeInsets.symmetric(vertical: 6.0), child: new Row (
          children: [
            new Icon(
              Icons.email,
              color: Color.fromRGBO(237, 61, 0, 1.0)
            ),
            new Padding(padding: EdgeInsets.only(left:10.0), child: new Text (
              "Send Email",
              style: new TextStyle(fontWeight: FontWeight.bold)
            )),
            new Padding(padding: EdgeInsets.only(left:5.0), child: new InkWell ( 
              onTap: () {launch("mailto:info@dartstransit.com");},
              child: new Text (
              "info@dartstransit.com",
              style: new TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
            )))
          ]
          )))),
          new Padding(padding: EdgeInsets.only(left: 20.0, right: 20.0),child: new Container(decoration: new BoxDecoration(border: const Border(
          bottom: const BorderSide(width: 1.0, color: const Color.fromRGBO(232, 232, 232, 1.0)),
          )), child: new Padding(padding: EdgeInsets.symmetric(vertical: 6.0), child: new Row (
          children: [
            new Icon(
              Icons.launch,
              color: Color.fromRGBO(237, 61, 0, 1.0)
            ),
            new Padding(padding: EdgeInsets.only(left:10.0), child: new Text (
              "Visit Website",
              style: new TextStyle(fontWeight: FontWeight.bold)
            )),
            new Padding(padding: EdgeInsets.only(left:5.0), child: new InkWell ( 
              onTap: () {launch("https://www.dartstransit.com");},
              child: new Text (
              "www.dartstransit.com",
              style: new TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
            )))
          ]
        )))),
        new Padding(padding: EdgeInsets.only(left: 20.0, right: 20.0),child: new Container(decoration: new BoxDecoration(border: const Border(
          bottom: const BorderSide(width: 1.0, color: const Color.fromRGBO(232, 232, 232, 1.0)),
          )), child: new Padding(padding: EdgeInsets.symmetric(vertical: 6.0), child: new Row (
          children: [
            new Icon(
              Icons.fingerprint,
              color: Color.fromRGBO(237, 61, 0, 1.0)
            ),
            new Padding(padding: EdgeInsets.only(left:10.0), child: new Text (
              "Privacy Policy",
              style: new TextStyle(fontWeight: FontWeight.bold)
            )),
            new Padding(padding: EdgeInsets.only(left:5.0), child: new InkWell ( 
              onTap: () {launch("https://www.triplinx.ca/en/legal-notice/1");},
              child: new Text (
              "Read Online",
              style: new TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
            )))
          ]
        )))),
          new Padding(padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0), child: new Column(mainAxisAlignment: MainAxisAlignment.center, children: [ 
            new Padding(padding: EdgeInsets.only(bottom: 11.0), child: new Text(
              "How did we do?",
              style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Color.fromRGBO(237, 61, 0, 1.0))
            )),
            RichText(
            textAlign: TextAlign.center,
            text: new TextSpan(
              // Note: Styles for TextSpans must be explicitly defined.
              // Child text spans will inherit styles from parent
              style: new TextStyle(
                fontSize: 12.0,
                color: Color.fromRGBO(74, 74, 74, 1.0)
              ),
              children: <TextSpan>[
                new TextSpan(text: 'If our service did not meet your expectations or you would like to enquire about other service options that might be available, please contact '),
                new TextSpan(text: 'DARTS:', style: new TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: Color.fromRGBO(74, 74, 74, 1.0),
                // outlineColor: Color.fromRGBO(237, 61, 0, 1.0),
                textStyle: TextStyle(color: Colors.white),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.phone,
                    color: Color.fromRGBO(237, 61, 0, 1.0),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text("Call DARTS 905-529-1717"),
                  ),
                ],
              ),
              onPressed: () {
                launch("tel://905-529-1717");
              },
            ),
            new Padding(padding: EdgeInsets.all(20.0),child: new InkWell(onTap: () {launch("https://2gen.net");},child: new Image(image: AssetImage("images/created-by-2gen.png"), width: 100.0)))
          ])),
        ]
      ))
    );
  }
  @override
  void initState() {
    super.initState();
    widget.auth.currentUserID().then((response) {
      if(response != null) {
        setState((){id = response;});
      }
    });
    SharedPreferences.getInstance().then((response){
      prefs = response;
      var showLocationVal = prefs.getBool("showLocation") ?? false;
      var enableSynthesizerVal = prefs.getBool("enableSynthesizer") ?? false;
      setState(() {
        showLocation = showLocationVal;
        enableSynthesizer = enableSynthesizerVal;
      });
    });
  }
}