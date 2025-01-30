import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spot/user/screens/shopdetials.dart';
import 'dart:math' show asin, cos, pi, sin, sqrt;
import 'package:url_launcher/url_launcher.dart';

class UserShop extends StatefulWidget {
  const UserShop({super.key});

  @override
  State<UserShop> createState() => _UserShopState();
}

class _UserShopState extends State<UserShop> {
  double? userLat;
  double? userLng;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Could not open the URL.\n$e')),
      );
      print('Error launching URL: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getUserLocation();
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
    return earthRadius * c; // Returns distance in kilometers
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  Future<void> getUserLocation() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null || currentUser.email == null) {
        print('No user logged in or email is null');
        return;
      }

      // Query user_reg collection using email
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('user_reg')
          .where('email', isEqualTo: currentUser.email)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        var userDoc = userSnapshot.docs.first;

        if (userDoc.data() is Map &&
            (userDoc.data() as Map).containsKey('latitude') &&
            (userDoc.data() as Map).containsKey('longitude')) {
          setState(() {
            userLat = userDoc['latitude'];
            userLng = userDoc['longitude'];
          });
          print('User location retrieved: $userLat, $userLng');
        } else {
          print('Location data not found in user document');
        }
      } else {
        print('User document not found');
      }
    } catch (e) {
      print('Error getting user location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nearby Shops',
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search for a shop...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: userLat == null || userLng == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading location...\nLatitude: $userLat\nLongitude: $userLng',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('vendor_reg')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No shops found.'));
                }

                List<DocumentSnapshot> shops = snapshot.data!.docs;

                // Filter shops by search query
                if (searchQuery.isNotEmpty) {
                  shops = shops.where((shop) {
                    String name = shop['name'] ?? '';
                    return name.toLowerCase().contains(searchQuery);
                  }).toList();
                }

                // Sort shops by distance
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
                  itemCount: shops.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot vendorDoc = shops[index];
                    final String vendorName = vendorDoc['name'] ?? 'No Name';
                    final String imageUrl = vendorDoc['image'] ?? '';
                    final String vendorPhone = vendorDoc['phone'] ?? '';
                    final String vendorcategory = vendorDoc['category'] ?? '';

                    double distance = calculateDistance(
                      userLat!,
                      userLng!,
                      vendorDoc['latitude'] ?? 0,
                      vendorDoc['longitude'] ?? 0,
                    );

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Detailspage(
                              vendorData: {
                                'name': vendorName,
                                'image': imageUrl,
                                'phone': vendorPhone,
                                'distance': distance,
                                'latitude': vendorDoc['latitude'] ?? 0,
                                'longitude': vendorDoc['longitude'] ?? 0,
                                'email': vendorDoc['email'] ?? '',
                              },
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 6.0,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: imageUrl.isNotEmpty
                                  ? NetworkImage(imageUrl)
                                  : null,
                              child: imageUrl.isEmpty
                                  ? const Icon(Icons.person,
                                      size: 40, color: Colors.grey)
                                  : null,
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vendorName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    vendorcategory,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    '${distance.toStringAsFixed(1)} km away',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                final double vendorLat =
                                    vendorDoc['latitude'] ?? 0.0;
                                final double vendorLng =
                                    vendorDoc['longitude'] ?? 0.0;

                                if (vendorLat != 0.0 &&
                                    vendorLng != 0.0 &&
                                    vendorLat >= -90 &&
                                    vendorLat <= 90 &&
                                    vendorLng >= -180 &&
                                    vendorLng <= 180) {
                                  final String dynamicUrl =
                                      "https://www.google.com/maps/search/?api=1&query=$vendorLat,$vendorLng";
                                  print('Launching URL: $dynamicUrl');
                                  _launchURL(dynamicUrl);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Vendor location not available or invalid.')),
                                  );
                                }
                              },
                              icon: const Icon(Icons.location_on),
                              color: Colors.red,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
