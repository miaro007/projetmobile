import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'home_screen.dart';
import 'bird_list_screen.dart';
import 'species/species_list_screen.dart';
import 'profile_screen.dart';
import 'add_bird_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SpeciesListScreen(), // Guide
    const SizedBox(), // Placeholder for Identifier (Index 2)
    const BirdListScreen(),    // Listes
    const ProfileScreen(),     // Notes
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddBirdScreen()),
      );
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFFEFEAE4),
          indicatorColor: const Color(0xFFDCD2CB), 
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: const Color(0xFF624C54),
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            return const IconThemeData(
              color: Color(0xFF624C54),
              size: 26,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Guide',
            ),
            NavigationDestination(
              icon: Icon(FontAwesomeIcons.binoculars),
              label: 'Identifier',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_border),
              selectedIcon: Icon(Icons.bookmark),
              label: 'Listes',
            ),
            NavigationDestination(
              icon: Icon(Icons.format_list_bulleted),
              label: 'Notes',
            ),
          ],
        ),
      ),
    );
  }
}
