import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bird_bloc.dart';
import '../bloc/bird_state.dart';

class ExplorerScreen extends StatelessWidget {
  const ExplorerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Simulation d'une carte (Mapbox/Google Maps)
          Container(
            color: const Color(0xFFE3F2FD),
            child: Center(
              child: Image.network(
                'https://api.mapbox.com/styles/v1/mapbox/outdoors-v12/static/0.34,44.84,10,0/600x1200?access_token=YOUR_TOKEN',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, size: 80, color: Colors.blue[200]),
                    const SizedBox(height: 16),
                    const Text('Carte Interactive', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('Visualisez les observations proches de vous'),
                  ],
                ),
              ),
            ),
          ),
          
          // Barre de recherche flottante
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSearchCard(),
                  const SizedBox(height: 12),
                  _buildQuickFilters(),
                ],
              ),
            ),
          ),
          
          // Bouton "Hotspots" flottant
          Positioned(
            right: 16,
            bottom: 120,
            child: FloatingActionButton.extended(
              onPressed: () {},
              backgroundColor: Colors.white,
              foregroundColor: Colors.green[800],
              icon: const Icon(Icons.local_fire_department),
              label: const Text('Hotspots'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher un lieu ou une espèce...',
          prefixIcon: Icon(Icons.location_on, color: Colors.red),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip('Mes observations', true),
          _filterChip('Communauté', false),
          _filterChip('Espèces rares', false),
          _filterChip('Moins de 24h', false),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 12)),
        selected: isSelected,
        onSelected: (v) {},
        backgroundColor: Colors.white,
        selectedColor: Colors.green[700],
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
