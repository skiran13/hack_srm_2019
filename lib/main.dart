import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_static_maps/map_provider.dart';
import 'package:location/location.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  int _selectedTab = 0;
  final _pageOptions = [
    Text('Page 1'),
    Text('Page 2'),
    new MyHomePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(
        primarySwatch: Colors.lightBlue,
        accentColor: Colors.lightBlueAccent,
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Track Me'),
        ),
        body: _pageOptions[_selectedTab],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedTab,
          onTap: (int index) {
            setState(() {
              _selectedTab = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('Home'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              title: Text('Categories'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              title: Text('Search'),
            ),
          ],
        ),
      ),
      //new MyHomePage(title: 'Static Maps Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Location _location = new Location();
  StreamSubscription<Map<String, double>> _locationSub;
  Map<String, double> _currentLocation;
  List locations = [];
  String googleMapsApi = 'AIzaSyDoQ63i6i9oZm38nrIUSqlHXhv6nBIx2eE';
  TextEditingController _latController = new TextEditingController();
  TextEditingController _lngController = new TextEditingController();
  int zoom = 15;

  @override
  void initState() {
    super.initState();
    _locationSub = _location
        .onLocationChanged()
        .listen((Map<String, double> locationData) {
      setState(() {
        _currentLocation = {
          "latitude": locationData["latitude"],
          "longitude": locationData['longitude'],
        };
      });
    });
  }

  Future<Null> findUserLocation() async {
    Map<String, double> location;
    try {
      location = await _location.getLocation();
      setState(() {
        _currentLocation = {
          "latitude": location["latitude"],
          "longitude": location['longitude'],
        };
      });
      print(location);
    } catch (exception) {
      print(exception);
    }
  }

  void handleSubmitNewMarker() {
    String lat;
    String lng;
    lat = _latController.text;
    lng = _lngController.text;

    setState(() {
      locations.add({"latitude": lat, "longitude": lng});
    });
    _lngController.clear();
    _latController.clear();
  }

  void increaseZoom() {
    setState(() {
      zoom = zoom + 1;
    });
  }

  void decreaseZoom() {
    setState(() {
      zoom = zoom - 1;
    });
  }

  void resetMap() {
    setState(() {
      _currentLocation = null;
      locations = [];
      zoom = 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    var isActiveColor =
        (locations.length <= 1) ? Theme.of(context).primaryColor : Colors.grey;

    Widget body = new Container(
      child: new Column(
        children: <Widget>[
          // Map Section w/ +/- buttons
          new Stack(
            children: <Widget>[
              new StaticMap(googleMapsApi,
                  currentLocation: _currentLocation,
                  markers: locations,
                  zoom: zoom),
              new Positioned(
                top: 130.0,
                right: 10.0,
                child: new FloatingActionButton(
                  onPressed: (locations.length <= 1) ? increaseZoom : null,
                  backgroundColor: isActiveColor,
                  child: new Icon(
                    const IconData(0xe145, fontFamily: 'MaterialIcons'),
                  ),
                ),
              ),
              new Positioned(
                top: 190.0,
                right: 10.0,
                child: new FloatingActionButton(
                  onPressed: (locations.length <= 1) ? decreaseZoom : null,
                  backgroundColor: isActiveColor,
                  child: new Icon(
                    const IconData(0xe15b, fontFamily: 'MaterialIcons'),
                  ),
                ),
              ),
            ],
          ),
          // Get Location & Reset Button Section
          new Container(
            margin: const EdgeInsets.only(top: 5.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new RaisedButton(
                  onPressed: findUserLocation,
                  child: new Text('Get My Current Location'),
                  color: Theme.of(context).primaryColor,
                ),
                new RaisedButton(
                  onPressed: resetMap,
                  child: new Text('Reset Map'),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
          // Marker Placement Input Section
          new Container(
            margin: new EdgeInsets.symmetric(horizontal: 25.0, vertical: 25.0),
            child: new Column(
              children: <Widget>[
                new TextField(
                    controller: _latController,
                    decoration: const InputDecoration(
                      labelText: 'latitude',
                    )),
                new TextField(
                    controller: _lngController,
                    decoration: const InputDecoration(
                      labelText: 'longitude',
                    )),
                new Container(
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  child: new RaisedButton(
                    onPressed: handleSubmitNewMarker,
                    child: new Text('Place Marker'),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      body: body,
    );
  }
}
