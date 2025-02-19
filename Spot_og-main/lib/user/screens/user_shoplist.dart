import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
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

  Future<void> logShopAnalytics(String vendorId, String eventType) async {
    try {
      final String today = DateTime.now().toIso8601String().split('T')[0];
      final String userId =
          FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

      // Update daily analytics
      final dailyDocRef = FirebaseFirestore.instance
          .collection('shop_analytics_daily')
          .doc('${vendorId}_$today');

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot dailyDoc = await transaction.get(dailyDocRef);

        if (!dailyDoc.exists) {
          transaction.set(dailyDocRef, {
            'vendorId': vendorId,
            'date': today,
            'views': eventType == 'view' ? 1 : 0,
            'mapClicks': eventType == 'location_clicks' ? 1 : 0,
            'uniqueVisitors': [userId],
            'timestamp': FieldValue.serverTimestamp(),
          });
        } else {
          Map<String, dynamic> data = dailyDoc.data() as Map<String, dynamic>;
          List<dynamic> visitors = List.from(data['uniqueVisitors'] ?? []);

          if (!visitors.contains(userId)) {
            visitors.add(userId);
          }

          transaction.update(dailyDocRef, {
            eventType == 'view' ? 'views' : 'mapClicks':
                FieldValue.increment(1),
            'uniqueVisitors': visitors,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      });

      // Update summary analytics
      await FirebaseFirestore.instance
          .collection('shop_analytics_summary')
          .doc(vendorId)
          .set({
        'totalViews': FieldValue.increment(eventType == 'view' ? 1 : 0),
        'totalMapClicks':
            FieldValue.increment(eventType == 'location_clicks' ? 1 : 0),
        'lastUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error logging analytics: $e');
    }
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
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          // Custom Sliver App Bar with Search
          SliverAppBar(
            expandedHeight: 140,
            floating: true,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(bottom: 80),
              title: const Text(
                'Nearby Shops',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              centerTitle: true,
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Search for a shop...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              setState(() => searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          const BorderSide(color: Colors.amber, width: 2),
                    ),
                  ),
                  onChanged: (value) =>
                      setState(() => searchQuery = value.toLowerCase()),
                ),
              ),
            ),
          ),

          // Location Loading State
          if (userLat == null || userLng == null)
            const SliverFillRemaining(
              child: LocationLoadingWidget(),
            )
          else
            // Shops List
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('vendor_reg')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const ShopLoadingCard(),
                        childCount: 5,
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: ErrorStateWidget(error: snapshot.error.toString()),
                  );
                }

                List<DocumentSnapshot> shops = snapshot.data?.docs ?? [];

                if (searchQuery.isNotEmpty) {
                  shops = shops.where((shop) {
                    String name = shop['name']?.toString().toLowerCase() ?? '';
                    String category =
                        shop['category']?.toString().toLowerCase() ?? '';
                    return name.contains(searchQuery) ||
                        category.contains(searchQuery);
                  }).toList();
                }

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

                if (shops.isEmpty) {
                  return const SliverFillRemaining(
                    child: EmptyStateWidget(),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final shop = shops[index];
                        return ShopCard(
                          shop: shop,
                          distance: calculateDistance(
                            userLat!,
                            userLng!,
                            shop['latitude'] ?? 0,
                            shop['longitude'] ?? 0,
                          ),
                          onTap: () => _handleShopTap(shop),
                          onLocationTap: () => _handleLocationTap(shop),
                        );
                      },
                      childCount: shops.length,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _handleShopTap(DocumentSnapshot shop) async {
    try {
      await logShopAnalytics(shop.id, 'view');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Detailspage(
            vendorData: {
              'name': shop['name'] ?? '',
              'vendorId': shop['vendorId'] ?? '',
              'image': shop['image'] ?? '',
              'phone': shop['phone'] ?? '',
              'latitude': shop['latitude'] ?? 0,
              'longitude': shop['longitude'] ?? 0,
              'email': shop['email'] ?? '',
              'id': shop.id,
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error handling shop tap: $e');
    }
  }

  void _handleLocationTap(DocumentSnapshot shop) async {
    try {
      await logShopAnalytics(shop.id, 'location_clicks');
      final double lat = shop['latitude'] ?? 0.0;
      final double lng = shop['longitude'] ?? 0.0;

      if (lat != 0.0 && lng != 0.0) {
        _launchURL("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location not available')),
        );
      }
    } catch (e) {
      debugPrint('Error handling location tap: $e');
    }
  }
}

class ShopCard extends StatelessWidget {
  final DocumentSnapshot shop;
  final double distance;
  final VoidCallback onTap;
  final VoidCallback onLocationTap;

  const ShopCard({
    super.key,
    required this.shop,
    required this.distance,
    required this.onTap,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Hero(
                  tag: 'shop_image_${shop.id}',
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: shop['image']?.isNotEmpty == true
                          ? DecorationImage(
                              image: NetworkImage(shop['image']),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: Colors.grey[200],
                    ),
                    child: shop['image']?.isEmpty == true
                        ? const Icon(Icons.store, size: 40, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop['name'] ?? 'No Name',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        shop['category'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
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
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onLocationTap,
                  icon: const Icon(Icons.directions),
                  color: const Color.fromARGB(255, 169, 28, 6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LocationLoadingWidget extends StatelessWidget {
  const LocationLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
          ),
          const SizedBox(height: 24),
          Text(
            'Getting your location...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ShopLoadingCard extends StatelessWidget {
  const ShopLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_mall_directory_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No shops found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String error;

  const ErrorStateWidget({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
