import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapboxMap _mapboxMap;
  final String accessToken =
      "MAPBOX_ACCESS_TOKEN"; // Replace with your Mapbox token
  CameraOptions? _initialCameraOptions;
  bool _permissionGranted = false;
  PointAnnotation? _userLocationMarker;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Get the user's current location
      geolocator.Position position = await _getCurrentPosition();

      // Save the location to Firebase
      await _saveLocationToFirestore(position);

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

  Future<void> _saveLocationToFirestore(geolocator.Position position) async {
    try {
      // Get the current user
      User? currentUser = FirebaseAuth.instance.currentUser;

      // Check if the user is logged in and has an email
      if (currentUser != null && currentUser.email != null) {
        String userEmail = currentUser.email!; // Get the user's email

        // Query the document using the email field
        QuerySnapshot querySnapshot = await _firestore
            .collection('user_reg')
            .where('email', isEqualTo: userEmail)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Get the document ID of the matching user
          String docId = querySnapshot.docs.first.id;

          // Update the document with latitude and longitude
          await _firestore.collection('user_reg').doc(docId).update({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'updated_at': FieldValue.serverTimestamp(),
          });
          debugPrint("Location saved to Firestore for user: $userEmail.");
        } else {
          debugPrint("User with email $userEmail not found.");
        }
      } else {
        debugPrint("No logged-in user or email is null.");
      }
    } catch (e) {
      debugPrint("Error saving location to Firestore: $e");
    }
  }

  void _startLocationUpdates() {
    geolocator.Geolocator.getPositionStream(
      locationSettings: const geolocator.LocationSettings(
        accuracy: geolocator.LocationAccuracy.high,
        distanceFilter: 10, // Updates when the user moves 10 meters
      ),
    ).listen((geolocator.Position position) {
      _updateUserLocationMarker(position);
      _saveLocationToFirestore(position); // Save updated location to Firestore
    });
  }

  Future<void> _updateUserLocationMarker(geolocator.Position position) async {
    // Move the camera to the user's current location
    await _mapboxMap.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(position.longitude, position.latitude),
        ),
        zoom: 17.0,
      ),
    );

    // Get the annotation manager for handling markers
    final annotationManager =
        await _mapboxMap.annotations.createPointAnnotationManager();

    // Remove the previous marker if it exists
    if (_userLocationMarker != null) {
      await annotationManager.delete(_userLocationMarker!);
    }

    // Add a new marker for the current location
    _userLocationMarker = await annotationManager.create(PointAnnotationOptions(
      geometry:
          Point(coordinates: Position(position.longitude, position.latitude)),
      iconImage: 'assets/point.png', // Updated to use asset path
      iconSize: 1.5,
    ));
    setState(() {}); // Update the UI if required
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
        title: const Text(
          'Spot',
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
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
