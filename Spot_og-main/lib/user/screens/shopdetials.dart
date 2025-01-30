import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Detailspage extends StatelessWidget {
  final Map<String, dynamic> vendorData;

  const Detailspage({
    Key? key,
    required this.vendorData,
  }) : super(key: key);

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp(String phone, BuildContext context) async {
    try {
      // Remove any non-numeric characters from the phone number
      String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

      // Add country code if not present (assuming Indian numbers)
      if (!cleanPhone.startsWith('91')) {
        cleanPhone = '91$cleanPhone';
      }

      // Create WhatsApp URL
      final Uri whatsappUri = Uri.parse('https://wa.me/$cleanPhone');

      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        // Show error message if WhatsApp is not installed
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('WhatsApp is not installed')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching WhatsApp: $e')),
        );
      }
      print('Error launching WhatsApp: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          vendorData['name'],
          style:
              const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vendorData['image']?.isNotEmpty ?? false)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(vendorData['image']),
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
                    vendorData['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${vendorData['distance'].toStringAsFixed(1)} km away',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (vendorData['Description']?.isNotEmpty ?? false) ...[
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vendorData['Description'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                  ],
                  ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.red),
                    title: Text(
                        vendorData['address'] ?? 'Click here to find location'),
                    onTap: () {
                      final dynamicUrl =
                          "https://www.google.com/maps/search/?api=1&query=${vendorData['latitude']},${vendorData['longitude']}";
                      _launchURL(dynamicUrl);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone, color: Colors.green),
                    title: Text(vendorData['phone']),
                    onTap: () => _launchPhone(vendorData['phone']),
                  ),
                  ListTile(
                    leading: Image.asset(
                      'assets/whatsapp-icons.png',
                      height: 30,
                      width: 30,
                    ),
                    title: Text('Chat on WhatsApp'),
                    onTap: () => _launchWhatsApp(vendorData['phone'], context),
                  ),
                  if (vendorData['email']?.isNotEmpty ?? false)
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.blue),
                      title: Text(vendorData['email']),
                      onTap: () => _launchURL('mailto:${vendorData['email']}'),
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
