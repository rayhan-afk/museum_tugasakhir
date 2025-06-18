import 'package:flutter/material.dart';

class SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const SocialIcon({Key? key, required this.icon, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
          ),
        ),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Icon(
            icon,
            size: 20,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
