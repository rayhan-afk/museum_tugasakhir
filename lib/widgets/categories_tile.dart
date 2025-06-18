import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoriesTile extends StatelessWidget {
  CategoriesTile({
    Key? key,
    required this.imageUrl,
    required this.text,
  }) : super(key: key);

  String imageUrl;
  String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFFFFD54F),
            borderRadius: BorderRadius.circular(23),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Image.asset(
              imageUrl,
              width: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 79, 76, 76),
          ),
        )
      ],
    );
  }
}

//193040044
//rayhan abduhuda
