import 'package:flutter/material.dart';
import 'package:wsa2/screens/E_contacts.dart/eme_contacts.dart';
import 'package:wsa2/screens/folder and contacts/folder.dart';
import 'package:wsa2/screens/mainHome.dart';
import 'package:wsa2/screens/map/map1.dart';
import 'package:wsa2/screens/recording/RecordingPage.dart';
import 'package:wsa2/screens/video/video.dart';
import '../Theme/colors.dart';

class WSABottomBar extends StatefulWidget {
  final int currentIndex;

  const WSABottomBar({super.key, required this.currentIndex});

  @override
  State<WSABottomBar> createState() => _WSABottomBarState();
}

class _WSABottomBarState extends State<WSABottomBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  void _onTap(int index) {
    if (index == _currentIndex) return;

    setState(() => _currentIndex = index);

    // 🔒 LOGIC UNCHANGED
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Homepage()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecordingScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VideoListPage(videos: videos)),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ContactPage()),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MapPage()),
      );
    }
  }

  Widget _navIcon(IconData icon, int index) {
    final bool isActive = _currentIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: isActive ? 28 : 24,
        color: isActive ? AppColors.primary : Colors.grey.shade500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,

        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey.shade500,

        selectedFontSize: 12,
        unselectedFontSize: 11,

        onTap: _onTap,

        items: [
          BottomNavigationBarItem(
            icon: _navIcon(Icons.home_rounded, 0),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _navIcon(Icons.mic_rounded, 1),
            label: 'Record',
          ),
          BottomNavigationBarItem(
            icon: _navIcon(Icons.video_library_rounded, 2),
            label: 'Videos',
          ),
          BottomNavigationBarItem(
            icon: _navIcon(Icons.phone_in_talk_rounded, 3),
            label: 'Emergency',
          ),
          BottomNavigationBarItem(
            icon: _navIcon(Icons.person_rounded, 4),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
