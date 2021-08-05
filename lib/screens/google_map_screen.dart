import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({Key key}) : super(key: key);

  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  var _initialCameraPosition, updateCam;

  Completer<GoogleMapController> _controller = Completer();
  LatLng currentLocation, destinationLocation;
  double lat, lng, distanceInMeters;
  Future<LocationData> findLocationData() async {
    Location location = Location();
    try {
      return location.getLocation();
    } catch (e) {
      return null;
    }
  }

  Future<Null> findLatLng() async {
    BitmapDescriptor pin = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'img/pin.png');
    LocationData locationData = await findLocationData();
    lat = locationData.latitude;
    lng = locationData.longitude;
    currentLocation = LatLng(locationData.latitude, locationData.longitude);
    destinationLocation = LatLng(locationData.latitude, locationData.longitude);
    _initialCameraPosition = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 15,
    );
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId('Pin'),
        icon: pin,
        //position: LatLng(13.728430, 100.534375),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
            title: 'ฉันอยู่นี่', snippet: 'latitude=$lat , longitude=$lng'),
      ));
      lines.add(currentLocation);
    });

    print('latitude=$lat , longitude=$lng');
  }

  Future followMap() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: destinationLocation,
      zoom: 15,
    )));
  }

  List<Marker> _markers = [];
  String googleAPiKey = 'AIzaSyBRgKu1bKSoG6qPvXSzubHps9E96x97R2A';

  _handleTap(LatLng tappedPoint) async {
    BitmapDescriptor pin = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'img/pin.png');
    print(tappedPoint);
    setState(
      () {
        _markers = [];
        _markers.add(
          Marker(
            markerId: MarkerId('Pin Point'),
            //position: LatLng(13.728430, 100.534375),
            icon: pin,
            position: tappedPoint,
            infoWindow: InfoWindow(
                title: 'ตำแหน่งหมุด',
                snippet:
                    'latitude=${tappedPoint.latitude} , longitude=${tappedPoint.longitude} '),
          ),
        );
        updateCam = CameraPosition(
          target: LatLng(lat, lng),
          zoom: 15,
        );
        destinationLocation = tappedPoint;
        lines.add(destinationLocation);
      },
    );

    distanceInMeters = await Geolocator.distanceBetween(
      currentLocation.latitude,
      currentLocation.longitude,
      destinationLocation.latitude,
      destinationLocation.longitude,
    );
  }

  List<LatLng> lines = [];

  @override
  void initState() {
    super.initState();
    findLatLng();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(child: (lat == null) ? loaDing() : showMap()));

  }

  Widget loaDing() {
    return Center(child: CircularProgressIndicator());
  }

  Widget showMap() {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Stack(
        children: [
          GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              polylines: {
                Polyline(
                    polylineId: PolylineId("p1"),
                    color: Colors.black,
                    width: 2,
                    points: lines)
              },
              onTap: _handleTap,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              markers: Set.from(_markers),
              mapType: MapType.normal,
              initialCameraPosition: _initialCameraPosition),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.075,
                margin: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 30.0),
                //padding: const EdgeInsets.all(15.0),
                decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.circular(45.0),
                  shape: BoxShape.rectangle,
                  color: Colors.white60.withOpacity(0.25),
                  boxShadow: <BoxShadow>[
                    new BoxShadow(
                      color: Colors.white60,
                      blurRadius: 5.0,
                      offset: new Offset(0.0, 0.0),
                    ),
                  ],
                ),
                child: Center(
                  child: (distanceInMeters != null)
                      ? Text(
                          (distanceInMeters / 1000).toStringAsFixed(2) + ' km',
                          style: new TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                          ),
                        )
                      : Text(
                          'เลือกจุดที่จะไป',
                          style: new TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                          ),
                        ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
