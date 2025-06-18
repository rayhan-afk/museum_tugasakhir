import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:museum_tugasakhir/screens/collections_screen.dart';
import 'package:museum_tugasakhir/screens/museum_screen.dart';
import 'package:museum_tugasakhir/screens/scanner_screen.dart';
import 'package:museum_tugasakhir/widgets/main_drawer.dart';

class Tabs extends StatefulWidget {
  const Tabs({Key? key}) : super(key: key);

  @override
  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  final pages = const [
    MuseumScreen(),
    ScannerScreen(),
    CollectionsScreen(),
  ];

  final List<String> pageTitles = const [
    'Museum',
    'Scanner',
    'Collections',
  ];

  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex < pageTitles.length
              ? pageTitles[_selectedIndex]
              : 'Unknown',
          style: GoogleFonts.montserrat(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(FontAwesomeIcons.bars),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
            ),
          ),
        ),
      ),
      drawer: const MainDrawer(),
      body: pages[_selectedIndex],
      backgroundColor: Colors.white,
      bottomNavigationBar: CircleNavBar(
        activeIndex: _selectedIndex,
        onTap: (index) {
          if (index != _selectedIndex) {
            setState(
              () {
                _selectedIndex = index;
              },
            );
          }
        },
        activeIcons: const [
          Icon(Icons.home, color: Color.fromARGB(255, 79, 76, 76), size: 30),
          Icon(Icons.qr_code_rounded,
              color: Color.fromARGB(255, 79, 76, 76), size: 30),
          Icon(Icons.library_books_sharp,
              color: Color.fromARGB(255, 79, 76, 76), size: 30),
        ],
        inactiveIcons: const [
          Icon(
            Icons.home,
            color: Color.fromARGB(255, 79, 76, 76),
            size: 24,
          ),
          Icon(Icons.qr_code_rounded,
              color: Color.fromARGB(255, 79, 76, 76), size: 24),
          Icon(Icons.library_books_sharp,
              color: Color.fromARGB(255, 79, 76, 76), size: 24),
        ],
        color: Colors.white,
        circleColor: Colors.white,
        height: 60,
        circleWidth: 60,
        // activeIndex: _selectedIndex,
        // onTap: (index) {
        //   // Define the onTabSelected callback
        //   if (index != _selectedIndex) {
        //     setState(() {
        //       _selectedIndex = index;
        //     });
        //   }
        // },
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        cornerRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        elevation: 3,
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
        ),
        circleGradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
        ),
      ),
    );
  }
}
