import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:math' show asin, cos, pi, sin, sqrt;

class MapScreenlist extends StatefulWidget {
  const MapScreenlist({Key? key}) : super(key: key);

  @override
  State<MapScreenlist> createState() => _MapScreenlistState();
}

class _MapScreenlistState extends State<MapScreenlist> {
  late MapboxMap _mapboxMap;
  final String accessToken = "MAPBOX_ACCESS_TOKEN";
  CameraOptions? _initialCameraOptions;
  bool _permissionGranted = false;
  PointAnnotation? _userLocationMarker;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double? userLat;
  double? userLng;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  // Calculate distance between two coordinates
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  Future<void> _initializeMap() async {
    try {
      geolocator.Position position = await _getCurrentPosition();
      await _saveLocationToFirestore(position);

      setState(() {
        userLat = position.latitude;
        userLng = position.longitude;
        _initialCameraOptions = CameraOptions(
          center: Point(
            coordinates: Position(position.longitude, position.latitude),
          ),
          zoom: 14.0,
        );
        _permissionGranted = true;
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
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.email != null) {
        String userEmail = currentUser.email!;
        QuerySnapshot querySnapshot = await _firestore
            .collection('user_reg')
            .where('email', isEqualTo: userEmail)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          String docId = querySnapshot.docs.first.id;
          await _firestore.collection('user_reg').doc(docId).update({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'updated_at': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      debugPrint("Error saving location to Firestore: $e");
    }
  }

  Widget _buildShopList() {
    if (userLat == null || userLng == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('vendor_reg').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        List<DocumentSnapshot> shops = snapshot.data?.docs ?? [];
        shops.sort((a, b) {
          double distanceA = calculateDistance(
            userLat!,
            userLng!,
            a['latitude'] ?? 0,
            a['longitude'] ?? 0,
          );
          double distanceB = calculateDistance(
            userLat!,
            userLng!,
            b['latitude'] ?? 0,
            b['longitude'] ?? 0,
          );
          return distanceA.compareTo(distanceB);
        });

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: shops.length,
          itemBuilder: (context, index) {
            final shop = shops[index];
            final distance = calculateDistance(
              userLat!,
              userLng!,
              shop['latitude'] ?? 0,
              shop['longitude'] ?? 0,
            );

            return GestureDetector(
              onTap: () {
                if (shop['latitude'] != null && shop['longitude'] != null) {
                  _mapboxMap.setCamera(
                    CameraOptions(
                      center: Point(
                        coordinates: Position(
                          shop['longitude'],
                          shop['latitude'],
                        ),
                      ),
                      zoom: 16.0,
                    ),
                  );
                }
              },
              child: Container(
                width: 125,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shop Image
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: shop['image']?.isNotEmpty == true
                          ? Image.network(
                              shop['image'],
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              height: 100,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: const Icon(Icons.store,
                                  size: 50, color: Colors.grey),
                            ),
                    ),

                    // Shop Name and Distance
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shop['name'] ?? 'Unknown Shop',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${distance.toStringAsFixed(1)} km away',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // App Bar
          Container(
            padding: const EdgeInsets.only(top: 40, bottom: 1.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.purple.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Text(
                'Spot',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),

          // Map Section
          Expanded(
            child: _initialCameraOptions != null
                ? MapWidget(
                    key: const ValueKey("mapWidget"),
                    cameraOptions: _initialCameraOptions,
                    onMapCreated: (MapboxMap mapboxMap) async {
                      _mapboxMap = mapboxMap;

                      if (_permissionGranted) {
                        // Start updating the location
                        _startLocationUpdates();
                      }

                      // Add a location marker
                      geolocator.Position position =
                          await _getCurrentPosition();
                      await _addMarker(position.latitude, position.longitude);
                    },
                    textureView: true,
                  )
                : const Center(child: CircularProgressIndicator()),
          ),

          // Horizontal Shop List
          Container(
            height: 250, // Fixed height for the horizontal shop list
            padding: const EdgeInsets.only(top: 1, bottom: 60),
            child: _buildShopList(),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: FloatingActionButton(
          onPressed: () async {
            try {
              await _getCurrentPosition();
              setState(() {
                _permissionGranted = true;
              });
              _startLocationUpdates();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Permission error: $e")),
              );
            }
          },
          child: const Icon(Icons.location_on),
          tooltip: 'Request Location Permission',
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _startLocationUpdates() {
    geolocator.Geolocator.getPositionStream(
      locationSettings: const geolocator.LocationSettings(
        accuracy: geolocator.LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((geolocator.Position position) {
      _updateUserLocationMarker(position);
      _saveLocationToFirestore(position);
    });
  }

  Future<void> _updateUserLocationMarker(geolocator.Position position) async {
    await _mapboxMap.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(position.longitude, position.latitude),
        ),
        zoom: 17.0,
      ),
    );

    final annotationManager =
        await _mapboxMap.annotations.createPointAnnotationManager();

    if (_userLocationMarker != null) {
      await annotationManager.delete(_userLocationMarker!);
    }

    _userLocationMarker = await annotationManager.create(PointAnnotationOptions(
      geometry:
          Point(coordinates: Position(position.longitude, position.latitude)),
      iconImage: 'assets/pointt.png',
      iconSize: 5.5,
    ));

    setState(() {});
  }

  Future<void> _addMarker(double latitude, double longitude) async {
    try {
      // Create an annotation manager
      final annotationManager =
          await _mapboxMap.annotations.createPointAnnotationManager();

      // Create a new marker at the given latitude and longitude
      _userLocationMarker =
          await annotationManager.create(PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(longitude, latitude),
        ),
        iconImage: 'assets/point.png', // Make sure the icon image exists
        iconSize: 5.5, // Adjust size as needed
      ));

      if (_userLocationMarker != null) {
        debugPrint("Marker created successfully.");
      } else {
        debugPrint("Failed to create marker.");
      }
    } catch (e) {
      debugPrint("Error adding marker: $e");
    }
  }
}
