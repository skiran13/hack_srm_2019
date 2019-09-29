import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_static_maps/map_provider.dart';
import 'package:location/location.dart';
import 'package:sms/sms.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

String textMessage, sender;
int _selectedTab = 0;

class MyAppState extends State<MyApp> {
  final _pageOptions = [
    new PhonePage(),
    new MyHomePage(),
  ];

  Location _location = new Location();
  Map<String, double> _currentLocation;
  Future<String> findUserLocation() async {
    Map<String, double> location;
    try {
      location = await _location.getLocation();
      setState(() {
        _currentLocation = {
          "latitude": location["latitude"],
          "longitude": location['longitude'],
        };
      });
      var message = location['latitude'].toString() +
          ',' +
          location['longitude'].toString();
      return message;
    } catch (exception) {
      print('Exception:' + exception.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    new SmsReceiver().onSmsReceived.listen((SmsMessage msg) {
      if (msg.body == 'Trackmenibba') {
        Timer.periodic(new Duration(seconds: 10), (timer) {
          findUserLocation().then((val) {
            SmsSender sender = new SmsSender();
            sender.sendSms(new SmsMessage(msg.sender, val));
          });
        });
      }
    });
    return new MaterialApp(
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.lightBlueAccent,
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Track Me', style: TextStyle(fontFamily: 'Cabin')),
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
              title: Text('Home', style: TextStyle(fontFamily: 'Cabin')),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              title: Text('Search', style: TextStyle(fontFamily: 'Cabin')),
            ),
          ],
        ),
      ),
      //new MyHomePage(title: 'Static Maps Demo'),
    );
  }
}

class PhonePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PhonePageState();
  }
}

String phone;

class PhonePageState extends State<PhonePage> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Color hexToColor(String code) {
      return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
    }

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: new Material(
            child: new SingleChildScrollView(
                child: new Container(
                    padding: const EdgeInsets.all(30.0),
                    color: Colors.white,
                    child: new Container(
                      child: new Center(
                          child: new Column(children: [
                        new Padding(padding: EdgeInsets.only(top: 100.0)),
                        new Icon(
                          IconData(0xe1b3, fontFamily: 'MaterialIcons'),
                          size: 150,
                          color: Colors.redAccent,
                        ),
                        new Padding(padding: EdgeInsets.only(top: 120.0)),
                        new Text(
                          'Enter the',
                          style: new TextStyle(
                              color: Colors.blue,
                              fontSize: 25.0,
                              fontFamily: 'Cabin'),
                        ),
                        new Text(
                          'Phone Number to Track',
                          style: new TextStyle(
                              color: Colors.blue,
                              fontSize: 25.0,
                              fontFamily: 'Cabin'),
                        ),
                        new Padding(padding: EdgeInsets.only(top: 20.0)),
                        new Form(
                            key: formKey,
                            child: TextFormField(
                              decoration: new InputDecoration(
                                labelText: "Enter Phone Number",
                                fillColor: Colors.white,
                                border: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(25.0),
                                  borderSide: new BorderSide(),
                                ),
                                //fillColor: Colors.green
                              ),
                              onSaved: (input) => {phone = input},
                              validator: (val) {
                                if (val.length == 0) {
                                  return "Phone Number cannot be empty";
                                } else if (val.length > 10 || val.length < 10) {
                                  return "Phone Number is invalid";
                                } else {
                                  return null;
                                }
                              },
                              keyboardType: TextInputType.phone,
                              style: new TextStyle(
                                fontFamily: "Poppins",
                              ),
                            )),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: OutlineButton(
                                      textColor: Colors.blue,
                                      highlightedBorderColor: Colors.blue,
                                      onPressed: _submit,
                                      child: Text("Search",
                                          style:
                                              TextStyle(fontFamily: 'Cabin')),
                                      borderSide: BorderSide(
                                          color: Colors.blue,
                                          style: BorderStyle.solid,
                                          width: 0.8)))
                            ]),
                      ])),
                    )))));
  }

  void _submit() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      _selectedTab = 1;
      SmsSender sender = new SmsSender();
      sender.sendSms(new SmsMessage(phone, 'Trackmenibba'));
    }
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
  String googleMapsApi = 'AIzaSyA6F9F3OpbYRKEejnLZ5mZ711bLyoZeI14';
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
    new SmsReceiver().onSmsReceived.listen((SmsMessage msg) {
      var message = msg.body.split(',');
      _latController.text = message[0];
      _lngController.text = message[1];
      handleSubmitNewMarker();
    });
    Widget body = new Container(
      child: new Column(
        children: <Widget>[
          // Map Section w/ +/- buttons
          new Stack(
            children: <Widget>[
              new StaticMap(
                googleMapsApi,
                currentLocation: _currentLocation,
                markers: locations,
                zoom: zoom,
              ),
              new Positioned(
                bottom: 90.0,
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
                bottom: 20.0,
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
                new OutlineButton(
                    onPressed: findUserLocation,
                    child: new Text('Get My Current Location',
                        style: TextStyle(fontFamily: 'Cabin')),
                    color: Colors.blue,
                    textColor: Colors.blue,
                    borderSide: BorderSide(
                        color: Colors.blue,
                        style: BorderStyle.solid,
                        width: 0.8)),
                new OutlineButton(
                    onPressed: resetMap,
                    child: new Text('Reset Map',
                        style: TextStyle(fontFamily: 'Cabin')),
                    color: Colors.blue,
                    textColor: Colors.blue,
                    borderSide: BorderSide(
                        color: Colors.blue,
                        style: BorderStyle.solid,
                        width: 0.8)),
              ],
            ),
          ),
        ],
      ),
    );

    return new Scaffold(
      resizeToAvoidBottomInset: false, // set it to false
      body: SingleChildScrollView(child: body),
    );
  }
}
