import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wsa2/Theme/colors.dart';
import 'package:wsa2/screens/main_bottom_nav.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ContactPage(),
    );
  }
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  // 🔧 CLEAN NUMBER
  String cleanNumber(String number) {
    return number.replaceAll(RegExp(r'\s+'), '');
  }

  // 📞 CALL
  Future<void> callNumber(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: cleanNumber(number));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // 📍 LOCATION
  Future<String> getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return "https://www.google.com/maps?q=${position.latitude},${position.longitude}";
  }

  // 📩 SMS
  Future<void> sendSMS(String number) async {
    String location = await getLocation();
    String message =
        "🚨 EMERGENCY ALERT 🚨\nI am in danger.\n📍 Location:\n$location";

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: cleanNumber(number),
      queryParameters: {'body': message},
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri, mode: LaunchMode.externalApplication);
    }
  }

  // 🚨 BEAUTIFUL CARD
  Widget emergencyCard(
    String title,
    String number,
    IconData icon,
    Color color,
  ) {
    return Container(
      height: 65,
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(58, 0, 0, 0),
            blurRadius: 5,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: AppTextStyles.body3),
        subtitle: Text(number, style: AppTextStyles.body2),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () => callNumber(number),
            ),
            IconButton(
              icon: const Icon(Icons.sms, color: Colors.blue),
              onPressed: () => sendSMS(number),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // gradient: LinearGradient(
          //   colors: [Color(0xFFFF6F91), Color(0xFFFF9671)],
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          // ),
          color: AppColors.secondary,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 🔴 HEADER
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.verified_user,
                      color: AppColors.primary,
                      size: 50,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Women Safety Helplines",
                      style: AppTextStyles.heading,
                    ),
                    SizedBox(height: 5),
                    Text(
                      "One tap can save a life",
                      style: AppTextStyles.subHeading,
                    ),
                  ],
                ),
              ),

              // 📋 LIST
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        emergencyCard(
                          "Police",
                          "100",
                          Icons.local_police,
                          Colors.blue,
                        ),
                        emergencyCard(
                          "Ambulance",
                          "108",
                          Icons.local_hospital,
                          Colors.red,
                        ),
                        emergencyCard(
                          "Fire Station",
                          "101",
                          Icons.fire_truck,
                          Colors.orange,
                        ),
                        emergencyCard(
                          "Women Police",
                          "1091",
                          Icons.support_agent,
                          Colors.purple,
                        ),
                        emergencyCard(
                          "Women Helpline",
                          "1098",
                          Icons.woman,
                          Colors.pink,
                        ),
                        emergencyCard(
                          "Emergency Support",
                          "112",
                          Icons.warning,
                          Colors.redAccent,
                        ),
                        emergencyCard(
                          "Women in Distress",
                          "181",
                          Icons.favorite,
                          Colors.teal,
                        ),
                        emergencyCard(
                          "Cyber Crime",
                          "1930",
                          Icons.security,
                          Colors.brown,
                        ),
                        emergencyCard(
                          "Pranav Daud",
                          "9529476103",
                          Icons.person,
                          Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const WSABottomBar(currentIndex: 3),
    );
  }
}
