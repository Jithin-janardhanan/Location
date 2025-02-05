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
      appBar: AppBar(
        title: Text(
          widget.vendorData['name'],
          style:
              const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    vendorData: widget.vendorData,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.message),
            color: Colors.amber,
          )
        ],
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.vendorData['image']?.isNotEmpty ?? false)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.vendorData['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    widget.vendorData['name'],
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.red),
                    title: Text(widget.vendorData['address'] ??
                        'Click here to find location'),
                    onTap: () async {
                      String dynamicUrl =
                          "https://www.google.com/maps/search/?api=1&query=${widget.vendorData['latitude']},${widget.vendorData['longitude']}";

                      try {
                        await FirebaseFirestore.instance
                            .collection('shop_analytics')
                            .add({
                          'shopId': vendorId,
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
                  ListTile(
                    leading: const Icon(Icons.phone, color: Colors.green),
                    title: Text(widget.vendorData['phone']),
                    onTap: () => _launchPhone(widget.vendorData['phone']),
                  ),
                  ListTile(
                    leading: Image.asset('assets/whatsapp-icons.png',
                        height: 30, width: 30),
                    title: const Text('Chat on WhatsApp'),
                    onTap: () => _launchWhatsApp(widget.vendorData['phone']),
                  ),
                  if (widget.vendorData['email']?.isNotEmpty ?? false)
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.blue),
                      title: Text(widget.vendorData['email']),
                      onTap: () =>
                          _launchURL('mailto:${widget.vendorData['email']}'),
                    ),
                  const SizedBox(height: 20),
                  const Text('Rate & Review',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  RatingBar.builder(
                    initialRating: _rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 30,
                    itemBuilder: (context, _) =>
                        const Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: (rating) {
                      setState(() {
                        _rating = rating;
                      });
                    },
                  ),
                  TextField(
                    controller: _feedbackController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Write your feedback here...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    onPressed: _submitFeedback,
                    child: const Text('Submit Feedback',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
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
