// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:spot/user/screens/user_chat.dart';
// import 'package:url_launcher/url_launcher.dart';

// class Detailspage extends StatefulWidget {
//   final Map<String, dynamic> vendorData;

//   const Detailspage({Key? key, required this.vendorData}) : super(key: key);

//   @override
//   _DetailspageState createState() => _DetailspageState();
// }

// class _DetailspageState extends State<Detailspage> {
//   final TextEditingController _feedbackController = TextEditingController();
//   double _rating = 0.0;
//   late String vendorId; // Unique ID for feedback
//   String? currentUserEmail;

//   @override
//   void initState() {
//     super.initState();
//     vendorId = widget.vendorData['email'];
//     _fetchCurrentUserEmail();
//   }

//   Future<void> _fetchCurrentUserEmail() async {
//     String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
//     if (userId.isEmpty) return;

//     try {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('user_reg')
//           .doc(userId)
//           .get();

//       if (userDoc.exists) {
//         setState(() {
//           currentUserEmail = userDoc['email'];
//         });
//       }
//     } catch (e) {
//       debugPrint("Error fetching user email: $e");
//     }
//   }

//   Future<void> _submitFeedback() async {
//     if (vendorId.isEmpty || currentUserEmail == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error: Missing vendor or user info!')),
//       );
//       return;
//     }

//     String feedbackText = _feedbackController.text;
//     String userId = FirebaseAuth.instance.currentUser?.uid ?? 'Anonymous';

//     if (feedbackText.isEmpty || _rating == 0.0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please provide a rating and feedback')),
//       );
//       return;
//     }

//     try {
//       await FirebaseFirestore.instance.collection('feedback').add({
//         'vendorId': vendorId,
//         'userId': userId,
//         'userEmail': currentUserEmail,
//         'rating': _rating,
//         'comment': feedbackText,
//         'timestamp': FieldValue.serverTimestamp(),
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Feedback submitted successfully!')),
//       );

//       _feedbackController.clear();
//       setState(() {
//         _rating = 0.0;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error submitting feedback: $e')),
//       );
//     }
//   }

//   /// Launch a URL
//   Future<void> _launchURL(String url) async {
//     final Uri uri = Uri.parse(url);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     }
//   }

//   /// Launch phone call
//   Future<void> _launchPhone(String phone) async {
//     final Uri uri = Uri(scheme: 'tel', path: phone);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     }
//   }

//   /// Launch WhatsApp
//   Future<void> _launchWhatsApp(String phone) async {
//     try {
//       String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
//       if (!cleanPhone.startsWith('91')) {
//         cleanPhone = '91$cleanPhone';
//       }
//       final Uri whatsappUri = Uri.parse('https://wa.me/$cleanPhone');

//       if (await canLaunchUrl(whatsappUri)) {
//         await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('WhatsApp is not installed')),
//         );
//       }
//     } catch (e) {
//       print('Error launching WhatsApp: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           widget.vendorData['name'],
//           style:
//               const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ChatScreen(
//                     vendorData: widget.vendorData,
//                   ),
//                 ),
//               );
//             },
//             icon: const Icon(Icons.message),
//             color: Colors.amber,
//           )
//         ],
//         centerTitle: true,
//         backgroundColor: Colors.black,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (widget.vendorData['image']?.isNotEmpty ?? false)
//               Container(
//                 width: double.infinity,
//                 height: 200,
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: NetworkImage(widget.vendorData['image']),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 16),
//                   Text(
//                     widget.vendorData['name'],
//                     style: const TextStyle(
//                         fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   ListTile(
//                     leading: const Icon(Icons.location_on, color: Colors.red),
//                     title: Text(widget.vendorData['address'] ??
//                         'Click here to find location'),
//                     onTap: () async {
//                       String dynamicUrl =
//                           "https://www.google.com/maps/search/?api=1&query=${widget.vendorData['latitude']},${widget.vendorData['longitude']}";

//                       try {
//                         await FirebaseFirestore.instance
//                             .collection('shop_analytics')
//                             .add({
//                           'shopId': vendorId,
//                           'timestamp': FieldValue.serverTimestamp(),
//                           'eventType': 'location_click',
//                           'userId': FirebaseAuth.instance.currentUser?.uid ??
//                               'anonymous'
//                         });

//                         _launchURL(dynamicUrl);
//                       } catch (e) {
//                         debugPrint("Error logging location click: $e");
//                       }
//                     },
//                   ),
//                   ListTile(
//                     leading: const Icon(Icons.phone, color: Colors.green),
//                     title: Text(widget.vendorData['phone']),
//                     onTap: () => _launchPhone(widget.vendorData['phone']),
//                   ),
//                   ListTile(
//                     leading: Image.asset('assets/whatsapp-icons.png',
//                         height: 30, width: 30),
//                     title: const Text('Chat on WhatsApp'),
//                     onTap: () => _launchWhatsApp(widget.vendorData['phone']),
//                   ),
//                   if (widget.vendorData['email']?.isNotEmpty ?? false)
//                     ListTile(
//                       leading: const Icon(Icons.email, color: Colors.blue),
//                       title: Text(widget.vendorData['email']),
//                       onTap: () =>
//                           _launchURL('mailto:${widget.vendorData['email']}'),
//                     ),
//                   const SizedBox(height: 20),
//                   const Text('Rate & Review',
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 8),
//                   RatingBar.builder(
//                     initialRating: _rating,
//                     minRating: 1,
//                     direction: Axis.horizontal,
//                     allowHalfRating: true,
//                     itemCount: 5,
//                     itemSize: 30,
//                     itemBuilder: (context, _) =>
//                         const Icon(Icons.star, color: Colors.amber),
//                     onRatingUpdate: (rating) {
//                       setState(() {
//                         _rating = rating;
//                       });
//                     },
//                   ),
//                   TextField(
//                     controller: _feedbackController,
//                     maxLines: 3,
//                     decoration: InputDecoration(
//                       hintText: 'Write your feedback here...',
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8)),
//                     ),
//                   ),
//                   ElevatedButton(
//                     style:
//                         ElevatedButton.styleFrom(backgroundColor: Colors.amber),
//                     onPressed: _submitFeedback,
//                     child: const Text('Submit Feedback',
//                         style: TextStyle(
//                             color: Colors.black, fontWeight: FontWeight.bold)),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spot/user/screens/user_chat.dart';
import 'package:url_launcher/url_launcher.dart';

class Detailspage extends StatefulWidget {
  final Map<String, dynamic> vendorData;

  const Detailspage({Key? key, required this.vendorData}) : super(key: key);

  @override
  _DetailspageState createState() => _DetailspageState();
}

class _DetailspageState extends State<Detailspage> {
  final TextEditingController _feedbackController = TextEditingController();
  double _rating = 0.0;
  late String vendorId; // Unique ID for feedback
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    vendorId = widget.vendorData['email'];
    _fetchCurrentUserEmail();
  }

  Future<void> _fetchCurrentUserEmail() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('user_reg')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          currentUserEmail = userDoc['email'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching user email: $e");
    }
  }

  Future<void> _submitFeedback() async {
    if (vendorId.isEmpty || currentUserEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Missing vendor or user info!')),
      );
      return;
    }

    String feedbackText = _feedbackController.text;
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'Anonymous';

    if (feedbackText.isEmpty || _rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating and feedback')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('feedback').add({
        'vendorId': vendorId,
        'userId': userId,
        'userEmail': currentUserEmail,
        'rating': _rating,
        'comment': feedbackText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted successfully!')),
      );

      _feedbackController.clear();
      setState(() {
        _rating = 0.0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting feedback: $e')),
      );
    }
  }

  /// Launch a URL
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Launch phone call
  Future<void> _launchPhone(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Launch WhatsApp
  Future<void> _launchWhatsApp(String phone) async {
    try {
      String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
      if (!cleanPhone.startsWith('91')) {
        cleanPhone = '91$cleanPhone';
      }
      final Uri whatsappUri = Uri.parse('https://wa.me/$cleanPhone');

      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp is not installed')),
        );
      }
    } catch (e) {
      print('Error launching WhatsApp: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(50),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatScreen(vendorData: widget.vendorData),
                  ),
                );
              },
              icon: const Icon(Icons.message_rounded),
              color: Colors.amber,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image Section
            Stack(
              children: [
                if (widget.vendorData['image']?.isNotEmpty ?? false)
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(widget.vendorData['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Text(
                    widget.vendorData['name'],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Contact Information Cards
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Card
                  _buildContactCard(
                    icon: Icons.location_on,
                    iconColor: Colors.red,
                    title: 'Location',
                    subtitle: widget.vendorData['address'] ??
                        'Click to find location',
                    onTap: () async {
                      String dynamicUrl =
                          "https://www.google.com/maps/search/?api=1&query=${widget.vendorData['latitude']},${widget.vendorData['longitude']}";
                      try {
                        await FirebaseFirestore.instance
                            .collection('shop_analytics')
                            .add({
                          'shopId': widget.vendorData['id'],
                          'timestamp': FieldValue.serverTimestamp(),
                          'eventType': 'location_click',
                          'userId': FirebaseAuth.instance.currentUser?.uid ??
                              'anonymous'
                        });
                        _launchURL(dynamicUrl);
                      } catch (e) {
                        debugPrint("Error logging location click: $e");
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  // Contact Options Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildContactOptionCard(
                          icon: Icons.phone,
                          iconColor: Colors.green,
                          title: 'Call',
                          onTap: () => _launchPhone(widget.vendorData['phone']),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildContactOptionCard(
                          icon: Icons.chat,
                          iconColor: const Color(0xFF25D366),
                          title: 'WhatsApp',
                          onTap: () =>
                              _launchWhatsApp(widget.vendorData['phone']),
                        ),
                      ),
                      if (widget.vendorData['email']?.isNotEmpty ?? false) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildContactOptionCard(
                            icon: Icons.email,
                            iconColor: Colors.blue,
                            title: 'Email',
                            onTap: () => _launchURL(
                                'mailto:${widget.vendorData['email']}'),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Reviews Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rate & Review',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: RatingBar.builder(
                            initialRating: _rating,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 40,
                            unratedColor: Colors.grey[700],
                            itemBuilder: (context, _) => const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                _rating = rating;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _feedbackController,
                          maxLines: 3,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Share your experience...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            fillColor: Colors.grey[800],
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Colors.amber, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _submitFeedback,
                            child: const Text(
                              'Submit Review',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[400]),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildContactOptionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
