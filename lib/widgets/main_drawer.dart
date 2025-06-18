import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:museum_tugasakhir/widgets/icon_widget.dart';
import 'package:museum_tugasakhir/widgets/social_icon.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Museum Geologi',
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Bandung',
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.close,
                            size: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Container(
                  width: 260,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    image: const DecorationImage(
                      image: AssetImage('assets/image/museumgambar.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              IconWidget(
                icon: Icons.home,
                title: 'Home',
                onTap: () {
                  // Handle item 1 tap
                },
              ),
              IconWidget(
                icon: Icons.qr_code_sharp,
                title: 'Scanner',
                onTap: () {
                  // Handle item 2 tap
                },
              ),
              IconWidget(
                icon: Icons.library_books_sharp,
                title: 'Collections',
                onTap: () {
                  // Handle item 3 tap
                },
              ),
              IconWidget(
                icon: Icons.settings,
                title: 'Setting',
                onTap: () {
                  // Handle item 4 tap
                },
              ),
              const SizedBox(height: 250),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SocialIcon(
                    icon: Icons.facebook,
                    onTap: () {
                      // Handle Facebook tap
                    },
                  ),
                  SocialIcon(
                    icon: FontAwesomeIcons.instagram,
                    onTap: () {
                      // Handle Instagram tap
                    },
                  ),
                  SocialIcon(
                    icon: FontAwesomeIcons.twitter,
                    onTap: () {
                      // Handle Twitter tap
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
