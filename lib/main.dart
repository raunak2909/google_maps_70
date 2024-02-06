import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LatLng? currLatLng;
  Completer<GoogleMapController> mapCompleter = Completer<GoogleMapController>();


  @override
  void initState() {
    super.initState();
    getCurrLoc();
  }

  void getCurrLoc() async{

    if(await canGetLocation()){

      var currPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best
      );

      currLatLng = LatLng(currPos.latitude, currPos.longitude);

      print('Lat: ${currPos.latitude}, Lng: ${currPos.longitude}');

      var currCameraPos = CameraPosition(
          target: currLatLng!,
          zoom: 19,
        tilt: 90,
        bearing: 180
      );

      var mapController = await mapCompleter.future;
      mapController.animateCamera(CameraUpdate.newCameraPosition(currCameraPos));

      setState(() {

      });

    } else {
      print("Error: Location services or permissions are not enabled!!");
    }

  }

  Future<bool> canGetLocation() async{
    LocationPermission mLocPermission;
    var isServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if(isServiceEnabled){
      ///proceed further

      mLocPermission = await Geolocator.checkPermission();

      if(mLocPermission==LocationPermission.denied){

        mLocPermission = await Geolocator.requestPermission();

        if(mLocPermission == LocationPermission.denied){
          print("Error: Location permissions are denied!!");
          return false;
        } else if(mLocPermission == LocationPermission.deniedForever){
          print("Error: Location permissions are denied forever!!");
          return false;
        } else {
          return true;
        }

      } else if(mLocPermission == LocationPermission.deniedForever){
        print("Error: Location permissions are denied forever!!");
        return false;
      } else {
        return true;
      }


    } else {
      //Error dialog
      //snack bar
      print("Error: Location services are not enabled!!");
      return false;
    }



  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Maps'),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        onMapCreated: (mController){
          mapCompleter.complete(mController);
        },
        markers: {
          Marker(
            markerId: MarkerId("CurrPos"),
            infoWindow: InfoWindow(
              title: "Current Location",
              snippet: "I'm here"
            ),
            position: currLatLng ?? LatLng(26.2389, 73.0243)
          )
        },
        initialCameraPosition: CameraPosition(
            target: LatLng(26.2389, 73.0243),
            zoom: 19
        ),
      ),
    );
  }
}
