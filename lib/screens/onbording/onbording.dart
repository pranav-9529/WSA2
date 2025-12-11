import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wsa2/Theme/colors.dart';
import 'package:wsa2/screens/auth/login_page.dart';
import 'package:wsa2/screens/auth/signup_page.dart';
// import 'package:safecircle/Theme/colors.dart';

void main() {
  runApp(const SafeRouteApp());
}

class SafeRouteApp extends StatelessWidget {
  const SafeRouteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ImageCarouselScreen(),
    );
  }
}

/// ---------------- Auto-scrolling horizontal image carousel ----------------
class ImageCarouselScreen extends StatefulWidget {
  const ImageCarouselScreen({super.key});

  @override
  State<ImageCarouselScreen> createState() => _ImageCarouselScreenState();
}

class _ImageCarouselScreenState extends State<ImageCarouselScreen> {
  final PageController _controller = PageController(viewportFraction: 0.8);
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _pages = [
    {
      "image": "assets/images/safe.png",
      "title": "Safe Route",
      "description":
          "Get safe route suggestions, avoiding high-crime areas and providing real-time updates",
    },
    {
      "image": "assets/images/sos.png",
      "title": "SOS ",
      "description":
          "Press the SOS button to send alerts to emergency contacts and services",
    },
    {
      "image": "assets/images/track.png",
      "title": "Track me",
      "description":
          "Learn effective self-defense techniques to protect yourself with confidence",
    },
    {
      "image": "assets/images/defense.png",
      "title": "Self Defense",
      "description":
          "Track your safe route and stay connected with your loved ones",
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < _pages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _controller.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        page["image"]!,
                        height: 350,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 30),
                      Text(page["title"]!, style: AppTextStyles.heading),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Text(
                          page["description"]!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body1,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 50),

            /// Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primary
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            /// Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LoginPage()),
                        );
                      },
                      child: const Text(
                        "Sign in",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SignupPage()),
                        );
                      },
                      child: const Text(
                        "Sign up",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
