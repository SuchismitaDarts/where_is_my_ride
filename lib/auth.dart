import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

abstract class BaseAuth {
  Future<String> currentUser();
  Future<String> currentUserID();
  Future<String> signIn(String email, String password);
  Future<String> getError();
  Future<String> getBusData();
  Future<void> signOut();
}

class Auth implements BaseAuth {
  String error = "";
  Uri url = Uri.parse("https://services.dartstransit.com/ride/www1");
  var sampleData;
  Future<String> signIn(String user, String password) async {
    if(user == null || password == null) { return 'Error'; }
    final prefs = await SharedPreferences.getInstance();
    if(user == "1234" && password == "1234") {
      prefs.setString('user', user);
      prefs.setString('password', password);
      return user;
    }
    var connectivityResult = await (new Connectivity().checkConnectivity());

    var internet = true;

    /* Disabled for web
    
    var internet = false;
    if(connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          internet = true;
        }
      } on SocketException catch (_) {
        print('Not connected.');
      }
    }
    else {
      print('No network adapter.');
    }*/
    
    if(internet) {
      var response = await http.post(this.url, body: {"ClientId": user, "Password": password, "EventId": "-1"});
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      var data = jsonDecode(response.body);
      if(data["Message"] != null) {
        this.error = data["Message"];
        return 'Error';
      }
      else if(data["VehicleNumber"] == null) {
        this.error = "Your ride info is not ready yet. Information for your trip will be available 30 mins in advance of your ETA. Please try again later.";
        return 'Error';
      }
      else {
        prefs.setString('user', user);
        prefs.setString('password', password);
        return user;
      }
    }
    else {
      this.error = "No network connection.";
      return 'Error';
    }
  }

  Future<String> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return this.signIn(prefs.getString('user') as String, prefs.getString('password') as String);
  }

  Future<String> currentUserID() async {
    final prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString("user");
    if (user != null) {
      return user;
    } else {
      return "";
    }
  }


  Future<String> getBusData() async {
    final prefs = await SharedPreferences.getInstance();
    if(prefs.getString('user') == "1234"){
      if(this.sampleData == null) {
        this.sampleData = await this.getSampleData();
      }
      var response = this.sampleData[0];
      this.sampleData.removeRange(0, 1);
      return response;
    }
    if(prefs.getString('user') == null){return "";}
    var response = await http.post(this.url, body: {"ClientId": prefs.getString('user'), "Password": prefs.getString('password'), "EventId": "-1"});
    return response.body;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
    prefs.remove('password');
    return;
  }

  Future<String> getError() async {
    return this.error;
  }

  Future<List> getSampleData() async {
    var data = await rootBundle.loadString('data/sample-data.json');
    return data.split(";");
  }
}
