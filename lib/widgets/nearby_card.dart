import 'package:flutter/material.dart';
import 'package:wsa2/Theme/colors.dart';

class NearbyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const NearbyCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        width: 370,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Icon container
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: _iconBgColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _iconColor(), size: 26),
            ),

            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body3),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🎨 Dynamic icon color based on card type
  Color _iconColor() {
    if (title.toLowerCase().contains("police")) {
      return Colors.blue;
    }
    if (title.toLowerCase().contains("hospital")) {
      return const Color.fromARGB(255, 244, 54, 54);
    }
    return Colors.green;
  }

  Color _iconBgColor() {
    if (title.toLowerCase().contains("police")) {
      return Colors.blue.withOpacity(0.15);
    }
    if (title.toLowerCase().contains("hospital")) {
      return const Color.fromARGB(134, 76, 244, 54);
    }
    return Colors.green.withOpacity(0.15);
  }
}
