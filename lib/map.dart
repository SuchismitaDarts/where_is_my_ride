import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:where_is_my_ride/auth.dart';
import 'package:where_is_my_ride/CompositeSubscription.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MapPage extends StatefulWidget {
  MapPage({Key? key, required this.title, required this.auth}) : super(key: key);
  final String title;
  final BaseAuth auth;
  @override
  _MapPageState createState() => new _MapPageState();
}

class _MapPageState extends State<MapPage> {

  //Create an instance variable for the mapView
  late MapController mapController;
  late SharedPreferences prefs;
  static const resetTime = 60;
  var compositeSubscription = new CompositeSubscription();
  var location = new Location();
  var currentLocation = <String, double>{};
  var busLocation = <String, double>{};
  var showLocation;
  var enableSynthesizer = false;
  var busName = "Loading...";
  var arrival = "Loading...";
  var arrivalLabel = "Estimated arrival";
  var ride = "Loading...";
  var timeTillReset = 0;
  var data;
  List<Marker> _markers = <Marker>[];
  List<Polyline> _polylines = <Polyline>[];
  bool stop = false;
  bool centered = false;
  FlutterTts flutterTts = new FlutterTts();
  var ttsPlaying = false;
  var updating = false;

  void updateMarkers() {
    print("Updating markers...");
    updateLocation().then((response){
      print("Updating location...");
    });
    if(!this.stop) {
    widget.auth.getBusData().then((response) {
      if(response != null) {
        data = jsonDecode(response);
        print(data);
        if(data["Message"] == null && data["VehicleNumber"] != null) {
          _markers.clear();
          if(busLocation["latitude"] != null && (busLocation["latitude"] != data["Lat"] || busLocation["longitude"] != data["Lon"])) {
            var newLat = data["Lat"];
            var newLon = data["Lon"];
            var diffLat = busLocation["latitude"]! - newLat;
            var diffLon = busLocation["longitude"]! - newLon;
            moveBus(busLocation["latitude"],busLocation["longitude"],newLat,newLon,diffLat,diffLon,null,0);
          }
          else {
            setState(() => _markers.add(
              new Marker(
                width: 48.0,
                height: 64.0,
                point: LatLng(data["Lat"],data["Lon"]),
                builder: (ctx) => new Container(
                  key: new Key("blue"),
                  child: new Icon(
                    Icons.directions_bus,
                    color: Colors.red,
                    size: 48.0,
                  ),
                ),
              )
            ));
            if(showLocation != false) {
              _polylines.clear();
              setState(() => _markers.add(
                new Marker(
                  width: 48.0,
                  height: 64.0,
                  point: LatLng(currentLocation["latitude"]!, currentLocation["longitude"]!),
                  builder: (ctx) => new Container(
                    key: new Key("blue"),
                    child: new Icon(
                      Icons.accessibility,
                      color: Colors.red,
                      size: 48.0,
                    ),
                  ),
                )
              ));
              setState(() => _polylines.add(new Polyline(
                strokeWidth: 4.0,
                color: Theme.of(context).primaryColor,
                points: [
                  new LatLng(data["Lat"], data["Lon"]),
                  new LatLng(currentLocation["latitude"]!, currentLocation["longitude"]!),
                ]
              )));
            }
          }

          busLocation["latitude"] = data["Lat"];
          busLocation["longitude"] = data["Lon"];

          if(!centered) {
            centerOnBus();
            centered = true;
          }

          if(data["VehicleNumber"] != busName){setState(() => busName = data["VehicleNumber"]);}
          if(data["ETA"] != arrival){setState(() => arrival = data["ETA"]);}
          if(data["EstOnBoard"] != ride){setState(() => ride = data["EstOnBoard"]);}
          if(data["isPickup"]) { setState(() => arrivalLabel = "Estimated arrival for pick up"); }
          else { setState(() => arrivalLabel = "Estimated arrival for drop off"); }
          speakRideDetails();
        }
        else {
          stop = true;
          logout();
        }
      }
    });}
  }

  void speakRideDetails() {
    if(enableSynthesizer && !ttsPlaying) {
      var speak = "Your ";
      if(data["isPickup"]) {
        speak += "pick up ";
      } else {speak += "drop off ";}
      speak += "ETA is "+data["ETA"];
      speak += ". Your ride is vehicle number "+data["VehicleNumber"].split('').join(' ');
      speak += ". Your ride time is "+data["EstOnBoard"];
      setState(() => ttsPlaying = true);
      flutterTts.speak(speak).then((result) {
        if (result == 1) setState(() => ttsPlaying = false);
      });
    }
  }

  moveBus(lat,lon,newLat,newLon,diffLat,diffLon,marker,repeat) async {
    if(repeat < 30) {
      repeat++;
      if(marker != null) {
        _markers.clear();
      }
      lat -= (diffLat/30.0);
      lon -= (diffLon/30.0);
      marker = new Marker(
        width: 48.0,
        height: 64.0,
        point: LatLng(lat, lon),
        builder: (ctx) => new Container(
          key: new Key("blue"),
          child: new Icon(
            Icons.directions_bus,
            color: Colors.red,
            size: 48.0
          ),
        ),
      );
      setState((){_markers.add(marker);});
      if(showLocation != false) {
        _polylines.clear();
        setState(() => _markers.add(
          new Marker(
            width: 48.0,
            height: 64.0,
            point: LatLng(currentLocation["latitude"]!, currentLocation["longitude"]!),
            builder: (ctx) => new Container(
              key: new Key("blue"),
              child: new Icon(
                Icons.accessibility,
                color: Colors.red,
                size: 48.0
              )
            ),
          )
        ));
        setState(() => _polylines.add(new Polyline(
          strokeWidth: 4.0,
          color: Theme.of(context).primaryColor,
          points: [
            new LatLng(lat, lon),
            new LatLng(currentLocation["latitude"]!, currentLocation["longitude"]!),
          ]
        )));
      }
      new Timer(const Duration(milliseconds: 50), () {
        moveBus(lat,lon,newLat,newLon,diffLat,diffLon,marker,repeat);
      });
    }
  }

  centerOnBus() async {
    mapController.move(LatLng(busLocation["latitude"]!, busLocation["longitude"]!), mapController.zoom);
  }

  startTimer() async {
    updating = true;
    new Timer(const Duration(milliseconds: 1000), () {
      if(!stop) {
        if(timeTillReset > 0) {
          setState(() {timeTillReset -= 1;});
        } else {
          setState(() {timeTillReset = resetTime;});
          updateMarkers();
        }
        startTimer();
      } else {
        updating = false;
      }
    });
  }

  Future<bool> updateLocation() async {
    if(showLocation != false) {
      try {
        LocationData response = await location.getLocation();
        print(response);
        currentLocation["latitude"] = response.latitude!;
        currentLocation["longitude"] = response.longitude!;
        return true;
      } on PlatformException catch (e) {
        print(e);
        if (e.code == 'PERMISSION_DENIED') {
          print("LOCATION PERMISSION DENIED");
        } 
        else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
          print("LOCATION PERMISSION DENIED NEVER ASK");
        }
      }
      on Exception catch(e) {
        print(e);
      }
    }
    showLocation = false;
    return false;
  }

  logout() async {
    //_mapView.dismiss();
    compositeSubscription.cancel();
    widget.auth.signOut().then((result){
      Navigator.of(context).pushReplacementNamed('/login');
    });
  }
  handleAppLifecycleState() {
    AppLifecycleState _lastLifecyleState;
    SystemChannels.lifecycle.setMessageHandler((msg) {
      print('SystemChannels> $msg');
      switch (msg) {
        case "AppLifecycleState.paused":
          _lastLifecyleState = AppLifecycleState.paused;
          this.stop = true;
          break;
        case "AppLifecycleState.inactive":
          _lastLifecyleState = AppLifecycleState.inactive;
          this.stop = true;
          break;
        case "AppLifecycleState.resumed":
          _lastLifecyleState = AppLifecycleState.resumed;
          this.stop = false;
          setState(() {timeTillReset = 0;});
          if(!updating) {startTimer();}
          break;
        case "AppLifecycleState.suspending":
          _lastLifecyleState = AppLifecycleState.detached;
          this.stop = true;
          break;
        default:
      }
      return Future.value(msg);
    });
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
        ),
        actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Navigator.of(context).pushNamed('/menu');
              },
            )
          ],
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Flexible(
              child: new FlutterMap(
                mapController: mapController,
                options: new MapOptions(
                  center: new LatLng(43.2076, -79.8601),
                  zoom: 15.0,
                  maxZoom: 15.0,
                  minZoom: 10.0,
                ),
                layers: [
                  new TileLayerOptions(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c']),
                  new PolylineLayerOptions(polylines: _polylines),
                  new MarkerLayerOptions(markers: _markers)
                ],
              ),
            ),
            new Container(
              color: Color.fromRGBO(227, 227, 227, 1.0),
              width: double.infinity,
              child: new Padding(padding: centered ? EdgeInsets.all(10.0) : EdgeInsets.all(0.0),
                child: centered ? new Text(timeTillReset > 0 ? "Refresh in "+timeTillReset.toString()+" seconds" : "Refreshing...",
                style: new TextStyle(color: Color.fromRGBO(74, 74, 74, 1.0)),
                textAlign: TextAlign.center) : new Image(image: AssetImage("images/loader.gif"), height: 32.0),
              )
            ),
            new Padding(
              padding: new EdgeInsets.symmetric(horizontal: 20.0),
              child: new Column( children: [new Container( child: new Padding(padding: EdgeInsets.only(top:4.0, bottom: 4.0), child: new Row(
                children: [
                  Icon(
                    Icons.directions_bus,
                    color: Colors.grey,
                  ),
                  Padding(padding: EdgeInsets.only(left: 15.0), child: Text(
                    'Your ride is',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(74, 74, 74, 1.0)
                    ),
                  )),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          child: Text(
                            "Vehicle #"+busName,
                            style: new TextStyle(color: Color.fromRGBO(74, 74, 74, 1.0))
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )), decoration: new BoxDecoration(border: const Border(bottom: const BorderSide(width: 1.0, color: Color.fromRGBO(232, 232, 232, 1.0)),)),),
              new Container( child: new Padding(padding: EdgeInsets.only(top:4.0, bottom: 4.0), child: new Row(
                children: [
                  Icon(
                    Icons.update,
                    color: Colors.grey,
                  ),
                  new Container ( constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*.55), child: Padding(padding: EdgeInsets.only(left: 15.0), child: Text(
                    arrivalLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(74, 74, 74, 1.0)
                    ),
                  ))),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          child: Text(
                            arrival,
                            style: new TextStyle(color: Color.fromRGBO(74, 74, 74, 1.0))
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
              )), decoration: new BoxDecoration(border: const Border(bottom: const BorderSide(width: 1.0, color: Color.fromRGBO(232, 232, 232, 1.0)),)),),
              new Container( child: new Padding(padding: EdgeInsets.only(top:4.0, bottom: 4.0), child: new Row(
                children: [
                  Icon(
                    Icons.event_seat,
                    color: Colors.grey,
                  ),
                  Padding(padding: EdgeInsets.only(left: 15.0), child: Text(
                    'Ride Time',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(74, 74, 74, 1.0)
                    ),
                  )),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          child: Text(
                            ride,
                            style: new TextStyle(color: Color.fromRGBO(74, 74, 74, 1.0))
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
              )), decoration: new BoxDecoration(border: const Border(bottom: const BorderSide(width: 1.0, color: Color.fromRGBO(232, 232, 232, 1.0))))),
              new Padding(padding: EdgeInsets.all(0.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      textStyle: TextStyle(color: Colors.white),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.refresh),
                        Padding(padding: EdgeInsets.only(left:10.0), child: Text("Recenter Map"))
                      ],
                    ),
                    onPressed: () {centerOnBus();},
                  )
              )]
            ))
          ],
        ),
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    handleAppLifecycleState();
    mapController = new MapController();
    SharedPreferences.getInstance().then((response){  
      prefs = response;
      showLocation = prefs.getBool("showLocation") ?? false;
      enableSynthesizer = prefs.getBool("enableSynthesizer") ?? false;
      updateLocation().then((response) {
        if(response) {
          print("Location check passed.");
        }
        else {
          print("Location check failed.");
        }
        //updateMarkers();
        if(!updating) {startTimer();}
      });
    });
  }
}