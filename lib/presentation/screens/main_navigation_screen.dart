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
    const SpeciesListScreen(), // Guía
    const SizedBox(), // Placeholder for Identificar (Index 2)
    const BirdListScreen(),    // Listas
    const ProfileScreen(),     // Notas
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
      backgroundColor: const Color(0xFFEFEAE4),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEFEAE4),
          border: Border(
            top: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home, 'Inicio'),
                _buildNavItem(1, Icons.menu_book_outlined, Icons.menu_book, 'Guía'),
                _buildNavItem(2, FontAwesomeIcons.binoculars, FontAwesomeIcons.binoculars, 'Identificar', isSpecial: true),
                _buildNavItem(3, Icons.bookmark_border, Icons.bookmark, 'Listas'),
                _buildNavItem(4, Icons.format_list_bulleted, Icons.format_list_bulleted, 'Notas'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label, {bool isSpecial = false}) {
    final isSelected = _selectedIndex == index && !isSpecial;
    final color = isSelected || isSpecial ? const Color(0xFF624C54) : Colors.grey[500];
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: color,
            size: isSpecial ? 22 : 26, 
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
