import 'package:flutter/material.dart';

void main() {
  runApp(const WomenSafetyApp());
}

class WomenSafetyApp extends StatelessWidget {
  const WomenSafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.grey.withOpacity(0.4),
        title: const Text(
          "Women Safety App",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, color: Colors.black),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Teacher Colony,',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Sillod, Maharashtra',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.notifications_none, color: Colors.black),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink[100]!, Colors.pink[200]!],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Big SOS Circle
                      Material(
                        elevation: 6,
                        shape: const CircleBorder(),
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 226, 137, 113),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              'SOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Small Inner Circle
                      Material(
                        elevation: 4,
                        shape: const CircleBorder(),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 202, 24, 24),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              "SOS",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Nearby Police Station',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: const [
                        Icon(Icons.location_on, color: Colors.red, size: 20),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Satara Parisar police Station Chh.Sambhajinagar',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: const [
                        Icon(Icons.call, color: Colors.green, size: 20),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            '02482-230400',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const FeatureButtons(),
          ],
        ),
      ),

      bottomNavigationBar: Material(
        elevation: 10,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.mic), label: "Record"),
            BottomNavigationBarItem(icon: Icon(Icons.videocam), label: "Video"),
            BottomNavigationBarItem(
              icon: Icon(Icons.phone),
              label: "Helplines",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
          ],
        ),
      ),
    );
  }
}

class FeatureButtons extends StatelessWidget {
  const FeatureButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildFeatureCard("images/safe.png", "Safe Route"),
          buildFeatureCard("images/track.png", "Track me"),
          buildFeatureCard("images/friends.png", "Add Friends"),
        ],
      ),
    );
  }

  Widget buildFeatureCard(String imagePath, String title) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 120,
        height: 140,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
