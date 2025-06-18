import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:museum_tugasakhir/screens/details/appbar.dart';

class DetailScreen<T> extends StatelessWidget {
  final T data;
  final String Function(T) getTitle;
  final String Function(T) getYear;
  final String Function(T) getDescription;
  final String Function(T) getImage;
  final String Function(T) getCategoryIconPath; // <-- DITAMBAHKAN KEMBALI

  const DetailScreen({
    Key? key,
    required this.data,
    required this.getTitle,
    required this.getYear,
    required this.getDescription,
    required this.getImage,
    required this.getCategoryIconPath, // <-- DITAMBAHKAN KEMBALI
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          DetailSliverAppBar(
            data: data,
            getImage: getImage,
            getCategoryIconPath:
                getCategoryIconPath, // <-- Diteruskan ke SliverAppBar
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          getTitle(data),
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        getYear(data),
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  const Divider(color: Colors.grey, height: 1.0),
                  const SizedBox(height: 16.0),
                  Text(
                    getDescription(data),
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
