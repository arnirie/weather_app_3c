import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  static final LatLng _initialPosition =
      LatLng(15.987736541064997, 120.57350546121597);

  late GoogleMapController _mapController;

  Future<bool> checkServicePermission() async {
    LocationPermission _permission;
    //check location services
    bool isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      //snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              const Text('Please enable location services in the settings.')));
      return false;
    }
    _permission = await Geolocator.checkPermission();
    if (_permission == LocationPermission.denied) {
      _permission = await Geolocator.requestPermission();
      if (_permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text(
                'Location permission is denied. You cannot use this application without the location permission.')));
        return false;
      }
    }

    if (_permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text(
              'Location permission is denied. Please enable in the settings.')));
      return false;
    }

    return true;
  }

  Future<void> getCurrentLocation() async {
    if (!await checkServicePermission()) return;
    Geolocator.getPositionStream(
            locationSettings: LocationSettings(
                accuracy: LocationAccuracy.high, distanceFilter: 5))
        .listen((_position) {
      print(_position);
      updateMarker(LatLng(_position.latitude, _position.longitude));
    });
  }

  List<Marker> _markers = [
    Marker(
      markerId: MarkerId('initial'),
      position: _initialPosition,
      infoWindow: InfoWindow(title: 'Initial Location'),
    ),
  ];

  void updateMarker(LatLng _position) {
    CameraPosition _cameraPosition =
        CameraPosition(target: _position, zoom: 20);
    _mapController
        .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId('${_position.latitude + _position.longitude}'),
          position: _position,
          infoWindow: InfoWindow(title: 'Pinned Location'),
        ),
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          mapType: MapType.normal,
          zoomControlsEnabled: true,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          initialCameraPosition: CameraPosition(
            target: _initialPosition,
            zoom: 14,
            bearing: 0,
            tilt: 0,
          ),
          onTap: (_position) {
            print(_position);
            updateMarker(_position);
          },
          onMapCreated: (mapController) {
            _mapController = mapController;
          },
          markers: _markers.toSet(),
        ),
      ),
    );
  }
}
