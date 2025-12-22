import 'dart:async';
import 'package:flutter/material.dart';

class SosHomePage extends StatefulWidget {
  const SosHomePage({super.key});

  @override
  State<SosHomePage> createState() => _SosHomePageState();
}

class _SosHomePageState extends State<SosHomePage> {
  int _countdown = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        timer.cancel();
        triggerSOS();
      } else {
        setState(() {
          _countdown--;
        });
      }
    });
  }

  void triggerSOS() {
    // 🔴 TODO:
    // Send SMS
    // Share location
    // Call emergency contact
    debugPrint("🚨 SOS Triggered!");
  }

  void cancelSOS() {
    _timer?.cancel();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade900,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 20),

              const Text(
                "SOS ALERT",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 30),

              Text(
                _countdown.toString(),
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Sending alert in seconds...",
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: cancelSOS,
                child: const Text(
                  "CANCEL SOS",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
