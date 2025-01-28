// import 'package:flutter/material.dart';
// // import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

// class MapScreen extends StatelessWidget {
//   const MapScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Spot'),
//       ),
//       body: MapWidget(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapboxMap _mapboxMap;
  final String accessToken =
      "YOUR_MAPBOX_ACCESS_TOKEN"; // Replace with your Mapbox token
  CameraOptions? _initialCameraOptions;
  bool _permissionGranted = false;
  PointAnnotation? _userLocationMarker;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Get the user's current location
      geolocator.Position position = await _getCurrentPosition();

      // Set the initial camera position
      setState(() {
        _initialCameraOptions = CameraOptions(
          center: Point(
            coordinates: Position(position.longitude, position.latitude),
          ),
          zoom: 14.0,
        );
        _permissionGranted = true; // Update permission status
      });
    } catch (e) {
      debugPrint("Error initializing map: $e");
    }
  }

  Future<geolocator.Position> _getCurrentPosition() async {
    bool serviceEnabled =
        await geolocator.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    geolocator.LocationPermission permission =
        await geolocator.Geolocator.checkPermission();
    if (permission == geolocator.LocationPermission.denied) {
      permission = await geolocator.Geolocator.requestPermission();
      if (permission == geolocator.LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == geolocator.LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied. Cannot request permissions.');
    }

    return await geolocator.Geolocator.getCurrentPosition(
      desiredAccuracy: geolocator.LocationAccuracy.high,
    );
  }

  void _startLocationUpdates() {
    geolocator.Geolocator.getPositionStream(
      locationSettings: const geolocator.LocationSettings(
        accuracy: geolocator.LocationAccuracy.high,
        distanceFilter: 10, // Updates when the user moves 10 meters
      ),
    ).listen((geolocator.Position position) {
      _updateUserLocationMarker(position);
    });
  }

  Future<void> _updateUserLocationMarker(geolocator.Position position) async {
    // Move the camera to the new location
    _mapboxMap.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(position.longitude, position.latitude),
        ),
        zoom: 14.0,
      ),
    );

    // Add or update user location marker
    final annotationManager =
        await _mapboxMap.annotations.createPointAnnotationManager();

    // Remove the previous marker if it exists
    if (_userLocationMarker != null) {
      annotationManager.delete(_userLocationMarker!);
    }

    // Add a new marker
    _userLocationMarker = await annotationManager.create(PointAnnotationOptions(
      geometry:
          Point(coordinates: Position(position.longitude, position.latitude)),
      iconImage:
          "assets/images/pngtree-maps-pointer-with-circle-shadow-png-image_6068575.jpg", // Add a custom marker image in assets
      iconSize: 1.5, // Adjust marker size
    ));

    setState(() {});
  }

  Future<void> _requestPermission() async {
    try {
      await _getCurrentPosition();
      setState(() {
        _permissionGranted = true; // Update UI if permission is granted
      });
      _startLocationUpdates();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Permission error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Location'),
      ),
      body: _initialCameraOptions != null
          ? MapWidget(
              key: const ValueKey("mapWidget"),
              cameraOptions: _initialCameraOptions,
              onMapCreated: (MapboxMap mapboxMap) {
                _mapboxMap = mapboxMap;

                if (_permissionGranted) {
                  _startLocationUpdates();
                }
              },
              textureView: true,
            )
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _requestPermission();
        },
        child: const Icon(Icons.location_on),
        tooltip: 'Request Location Permission',
      ),
    );
  }
}
