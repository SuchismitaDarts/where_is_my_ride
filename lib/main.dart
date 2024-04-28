import 'package:flutter/material.dart';
import 'package:where_is_my_ride/root.dart';
import 'package:where_is_my_ride/auth.dart';
import 'package:where_is_my_ride/map.dart';
import 'package:where_is_my_ride/menu.dart';
import 'package:where_is_my_ride/login.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  final Auth auth = new Auth();
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'DARTS: Where is My Ride?',
      theme: new ThemeData(
        primarySwatch: dartsPrimary,
      ),
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      home: new RootPage(auth: new Auth()),
      routes: <String, WidgetBuilder> {
        // Set routes for using the Navigator.
        '/home': (BuildContext context) => new MapPage(title: 'where is my ride?', auth: auth),
        '/menu': (BuildContext context) => new MenuPage(title: 'where is my ride?', auth: auth),
        '/login': (BuildContext context) => new LoginPage(title: '', auth: auth)
      }
    );
  }

  //static const _dartsPrimary = 0xFF433B88;
  static const _dartsPrimary = 0xFF330d70;
  static const MaterialColor dartsPrimary = const MaterialColor(
    _dartsPrimary,
    const <int, Color>{
      50:  const Color(_dartsPrimary),
      100: const Color(_dartsPrimary),
      200: const Color(_dartsPrimary),
      300: const Color(_dartsPrimary),
      400: const Color(_dartsPrimary),
      500: const Color(_dartsPrimary),
      600: const Color(_dartsPrimary),
      700: const Color(_dartsPrimary),
      800: const Color(_dartsPrimary),
      900: const Color(_dartsPrimary),
    },
  );
}
