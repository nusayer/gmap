import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final formKey = GlobalKey<FormState>();
  String name;
  GoogleMapController mapController;
  Position position;
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // get the current position
  Future<Position> _getPosition() async {
    position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  //send the data to console
  void _submit() {
    formKey.currentState.save();
    print(name);
    print(position.latitude);
    print(position.longitude);
    Fluttertoast.showToast(
        msg: "Data send to console ",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          elevation: 0.1,
          backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
          title: Center(child: Text('Google map demo')),
        ),
        body: Center(
          child: FutureBuilder(
            future: _getPosition(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return gMap(context);
              }
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }

  Widget gMap(BuildContext context) {
    return GoogleMap(
        onMapCreated: _onMapCreated,
        mapType: MapType.hybrid,
        initialCameraPosition: CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 11.0,
        ),
        markers: Set.from([
          (Marker(
            markerId: MarkerId("current location"),
            draggable: true,
            onTap: () {
              //modal build
              showModalBottomSheet<void>(
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20.0))),
                isScrollControlled: true,
                backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
                context: context,
                builder: (BuildContext context) {
                  return Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: Container(
                      child: Wrap(
                        children: <Widget>[
                          Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                TextFormField(
                                  decoration: InputDecoration(
                                      labelText: "Name",
                                      labelStyle: TextStyle(
                                        color: Colors.white,
                                      )),
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  onSaved: (input) => name = input,
                                ),
                                TextFormField(
                                  initialValue: "Latitude: " +
                                      position.latitude.toString() +
                                      "," +
                                      "Longitude: " +
                                      position.longitude.toString(),
                                  decoration: InputDecoration(
                                    labelText: "Current Coordinates",
                                    labelStyle: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Center(
                            child: RaisedButton(
                                child: const Text('Submit'),
                                onPressed: () {
                                  _submit();
                                  Navigator.pop(context);
                                }),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            position: LatLng(position.latitude, position.longitude),
            infoWindow: InfoWindow(title: "Current Location"),
          ))
        ]));
  }
}
