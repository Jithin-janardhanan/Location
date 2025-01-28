// import 'dart:convert';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;

// class usershop extends StatefulWidget {
//   usershop({super.key});

//   @override
//   State<usershop> createState() => _usershopState();
// }

// class _usershopState extends State<usershop> {
//   File? _image;

//   /// Picks an image from the gallery
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final CollectionReference vendorreg =
//         FirebaseFirestore.instance.collection('vendor_reg');

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Spot',
//           style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.black,
//       ),
//       body: StreamBuilder(
//         stream: vendorreg.snapshots(),
//         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text('No vendors found.'));
//           }

//           return ListView.builder(
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (context, index) {
//               final DocumentSnapshot vendorDoc = snapshot.data!.docs[index];
//               // final String vendorId = vendorDoc.id;
//               final String vendorName = vendorDoc['name'] ?? 'No Name';
//               final String imageUrl = vendorDoc['image'] ?? '';
//               final String vendorPhone = vendorDoc['phone'] ?? '';

//               return Container(
//                 margin: EdgeInsets.all(8.0),
//                 padding: EdgeInsets.all(12.0),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12.0),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.shade300,
//                       blurRadius: 6.0,
//                       offset: Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 40,
//                       backgroundImage:
//                           imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
//                       child: imageUrl.isEmpty
//                           ? Icon(Icons.person, size: 40, color: Colors.grey)
//                           : null,
//                     ),
//                     SizedBox(width: 16.0),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             vendorName,
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 4.0),
//                           Text(
//                             vendorPhone,
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(width: 16.0),

//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:latlong2/latlong.dart';

// class NearestShopsPage extends StatefulWidget {
//   const NearestShopsPage({Key? key}) : super(key: key);

//   @override
//   State<NearestShopsPage> createState() => _NearestShopsPageState();
// }

// class _NearestShopsPageState extends State<NearestShopsPage> {
//   List<Map<String, dynamic>> _shops = [];
//   LatLng? _currentLocation;

//   @override
//   void initState() {
//     super.initState();
//     _fetchCurrentLocation();
//   }

//   Future<void> _fetchCurrentLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);
//       setState(() {
//         _currentLocation = LatLng(position.latitude, position.longitude);
//       });
//       _fetchShops();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to get current location: $e')),
//       );
//     }
//   }

//   Future<void> _fetchShops() async {
//     try {
//       QuerySnapshot snapshot =
//           await FirebaseFirestore.instance.collection('vendor_reg').get();

//       List<Map<String, dynamic>> shops = snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return {
//           'name': data['name'],
//           'category': data['category'],
//           'description': data['Description'],
//           'location': data['location'],
//           'latitude': data['latitude'],
//           'longitude': data['longitude'],
//         };
//       }).toList();

//       if (_currentLocation != null) {
//         const Distance distance = Distance();
//         for (var shop in shops) {
//           final shopLatLng = LatLng(shop['latitude'], shop['longitude']);
//           shop['distance'] =
//               distance.as(LengthUnit.Kilometer, _currentLocation!, shopLatLng);
//         }
//         shops.sort((a, b) => (a['distance'] as double)
//             .compareTo(b['distance'] as double)); // Sort by distance
//       }

//       setState(() {
//         _shops = shops;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to fetch shops: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Nearest Shops'),
//         centerTitle: true,
//       ),
//       body: _currentLocation == null
//           ? Center(child: CircularProgressIndicator())
//           : _shops.isEmpty
//               ? Center(child: Text('No shops found near your location.'))
//               : ListView.builder(
//                   itemCount: _shops.length,
//                   itemBuilder: (context, index) {
//                     final shop = _shops[index];
//                     return ListTile(
//                       title: Text(shop['name']),
//                       subtitle: Text(
//                           '${shop['category']}\n${shop['description']}\nDistance: ${shop['distance'].toStringAsFixed(2)} km'),
//                       isThreeLine: true,
//                     );
//                   },
//                 ),
//     );
//   }
// }
// import 'dart:math';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:latlong2/latlong.dart';

// class NearestShopsPage extends StatefulWidget {
//   const NearestShopsPage({Key? key}) : super(key: key);

//   @override
//   State<NearestShopsPage> createState() => _NearestShopsPageState();
// }

// class _NearestShopsPageState extends State<NearestShopsPage> {
//   List<Map<String, dynamic>> _shops = [];
//   LatLng? _currentLocation;

//   @override
//   void initState() {
//     super.initState();
//     _fetchCurrentLocation();
//   }

//   // Fetch user's current location
//   Future<void> _fetchCurrentLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       setState(() {
//         _currentLocation = LatLng(position.latitude, position.longitude);
//       });
//       _fetchShops();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to get current location: $e')),
//       );
//     }
//   }

//   // Fetch shops from Firestore and calculate distances
//   Future<void> _fetchShops() async {
//     try {
//       QuerySnapshot snapshot =
//           await FirebaseFirestore.instance.collection('vendor_reg').get();

//       List<Map<String, dynamic>> shops = snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;

//         // Parse latitude and longitude safely as double
//         double latitude = double.tryParse(data['latitude'].toString()) ?? 0.0;
//         double longitude = double.tryParse(data['longitude'].toString()) ?? 0.0;

//         return {
//           'name': data['name'],
//           'category': data['category'],
//           'description': data['Description'],
//           'latitude': latitude,
//           'longitude': longitude,
//         };
//       }).toList();

//       if (_currentLocation != null) {
//         const Distance distance = Distance();
//         for (var shop in shops) {
//           final shopLatLng = LatLng(shop['latitude'], shop['longitude']);
//           shop['distance'] =
//               distance.as(LengthUnit.Kilometer, _currentLocation!, shopLatLng);
//         }
//         // Sort shops by distance in ascending order
//         shops.sort((a, b) =>
//             (a['distance'] as double).compareTo(b['distance'] as double));
//       }

//       setState(() {
//         _shops = shops;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to fetch shops: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Nearest Shops'),
//         centerTitle: true,
//       ),
//       body: _currentLocation == null
//           ? const Center(child: CircularProgressIndicator())
//           : _shops.isEmpty
//               ? const Center(child: Text('No shops found near your location.'))
//               : ListView.builder(
//                   itemCount: _shops.length,
//                   itemBuilder: (context, index) {
//                     final shop = _shops[index];
//                     return ListTile(
//                       title: Text(shop['name']),
//                       subtitle: Text(
//                         '${shop['category']}\n${shop['description']}\nDistance: ${shop['distance'].toStringAsFixed(2)} km',
//                       ),
//                       isThreeLine: true,
//                     );
//                   },
//                 ),
//     );
//   }
// }
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class NearestShopsPage extends StatefulWidget {
  const NearestShopsPage({Key? key}) : super(key: key);

  @override
  State<NearestShopsPage> createState() => _NearestShopsPageState();
}

class _NearestShopsPageState extends State<NearestShopsPage> {
  List<Map<String, dynamic>> _shops = [];
  LatLng? _currentLocation;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  // Fetch user's current location
  Future<void> _fetchCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      debugPrint(
          "Current location: ${position.latitude}, ${position.longitude}");
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      _fetchShops();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get current location: $e';
        _isLoading = false;
      });
    }
  }

  // Fetch shops from Firestore and calculate distances
  Future<void> _fetchShops() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('vendor_reg').get();

      List<Map<String, dynamic>> shops = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // Parse latitude and longitude safely as double
        double latitude = double.tryParse(data['latitude'].toString()) ?? 0.0;
        double longitude = double.tryParse(data['longitude'].toString()) ?? 0.0;

        return {
          'name': data['name'],
          'category': data['category'],
          'description': data['Description'],
          'latitude': latitude,
          'longitude': longitude,
        };
      }).toList();

      if (_currentLocation != null) {
        const Distance distance = Distance();
        for (var i = 0; i < shops.length; i++) {
          final shop = shops[i];
          final shopLatLng = LatLng(shop['latitude'], shop['longitude']);
          double shopDistance =
              distance.as(LengthUnit.Kilometer, _currentLocation!, shopLatLng);
          shops[i]['distance'] = shopDistance;
          debugPrint(
              "Shop ${shop['name']} distance: ${shopDistance.toStringAsFixed(2)} km");
        }
        // Sort shops by distance in ascending order
        shops.sort((a, b) =>
            (a['distance'] as double).compareTo(b['distance'] as double));
      }

      setState(() {
        _shops = shops;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch shops: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearest Shops'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _shops.isEmpty
                  ? const Center(
                      child: Text('No shops found near your location.'))
                  : ListView.builder(
                      itemCount: _shops.length,
                      itemBuilder: (context, index) {
                        final shop = _shops[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  shop['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  shop['category'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  shop['description'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Distance: ${shop['distance'].toStringAsFixed(2)} km',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
