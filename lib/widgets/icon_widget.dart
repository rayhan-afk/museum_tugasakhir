import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IconWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String title;

  const IconWidget({
    required this.icon,
    required this.onTap,
    required this.title,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
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
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }
}
