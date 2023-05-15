import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class CurrentLocationScreen extends StatefulWidget {
  const CurrentLocationScreen({super.key});

  @override
  State<CurrentLocationScreen> createState() => _CurrentLocationScreenState();
}

class _CurrentLocationScreenState extends State<CurrentLocationScreen> {
  Position? _position;

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

    _position = await Geolocator.getCurrentPosition();
    print('${_position!.latitude} long: ${_position!.longitude}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Lat: ${_position!.latitude}'),
            Text('Long: ${_position!.longitude}'),
            ElevatedButton(
              onPressed: getCurrentLocation,
              child: const Text('Get My Current Location'),
            )
          ],
        ),
      ),
    );
  }
}
