import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/bird_bloc.dart';
import '../bloc/bird_state.dart';
import '../../domain/models/bird.dart';
import 'bird_detail_screen.dart';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({super.key});

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  static const _primary = Color(0xFF624C54);
  static const _secondary = Color(0xFF90CDC6);
  static const _tertiary = Color(0xFFF6C69D);

  final MapController _mapController = MapController();
  String _activeFilter = 'Mes observations';
  final _searchCtrl = TextEditingController();
  Bird? _selectedBird;

  // Coordonnées par défaut (France)
  static const _defaultCenter = LatLng(46.603354, 1.888334);

  final List<String> _filters = [
    'Mes observations',
    'Espèces rares',
    'Moins de 24h',
    'Communauté',
  ];

  // Hotspots eBird simulés (dans une vraie app, viendraient de l'API)
  final List<_Hotspot> _hotspots = [
    _Hotspot('Parc des Oiseaux', LatLng(45.95, 4.89), 248),
    _Hotspot('Camargue', LatLng(43.5, 4.6), 512),
    _Hotspot('Baie de Somme', LatLng(50.21, 1.56), 387),
    _Hotspot('Forêt de Fontainebleau', LatLng(48.40, 2.70), 165),
    _Hotspot('Cap Ferret', LatLng(44.68, -1.25), 201),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BirdBloc, BirdState>(
      builder: (context, state) {
        final birds = state is BirdsLoaded ? state.birds : <Bird>[];
        final markers = _buildMarkers(birds);

        return Scaffold(
          body: Stack(
            children: [
              // ── Carte OpenStreetMap ──────────────────────────────────────
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _defaultCenter,
                  initialZoom: 6.0,
                  onTap: (_, __) => setState(() => _selectedBird = null),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.birdwatch.pro',
                    maxZoom: 19,
                  ),
                  MarkerLayer(markers: markers),
                  MarkerLayer(markers: _buildHotspotMarkers()),
                ],
              ),

              // ── Overlay UI ──────────────────────────────────────────────
              SafeArea(
                child: Column(
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 10),
                    _buildFilterChips(),
                  ],
                ),
              ),

              // ── Boutons flottants ────────────────────────────────────────
              Positioned(
                right: 16,
                bottom: _selectedBird != null ? 240 : 120,
                child: Column(
                  children: [
                    _buildMapButton(
                      Icons.add,
                      onTap: () => _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildMapButton(
                      Icons.remove,
                      onTap: () => _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildMapButton(
                      Icons.my_location,
                      color: _secondary,
                      onTap: () => _mapController.move(_defaultCenter, 7),
                    ),
                  ],
                ),
              ),

              // ── Bouton Hotspots ──────────────────────────────────────────
              Positioned(
                left: 16,
                bottom: _selectedBird != null ? 240 : 120,
                child: GestureDetector(
                  onTap: _showHotspotsSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _primary,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: _primary.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department,
                            color: _tertiary, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Hotspots',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Fiche observation sélectionnée ───────────────────────────
              if (_selectedBird != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBirdPreviewCard(_selectedBird!),
                ),

              // ── Compteur observations ─────────────────────────────────────
              Positioned(
                top: 120,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: _primary),
                      const SizedBox(width: 4),
                      Text(
                        '${birds.length} observation${birds.length != 1 ? 's' : ''}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Marker> _buildMarkers(List<Bird> birds) {
    return birds
        .where((b) => b.latitude != null && b.longitude != null)
        .map((b) {
      return Marker(
        point: LatLng(b.latitude!, b.longitude!),
        width: 44,
        height: 44,
        child: GestureDetector(
          onTap: () => setState(() => _selectedBird = b),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _selectedBird?.id == b.id ? _tertiary : _primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: _primary.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.flutter_dash,
                color: Colors.white, size: 20),
          ),
        ),
      );
    }).toList();
  }

  List<Marker> _buildHotspotMarkers() {
    return _hotspots.map((h) {
      return Marker(
        point: h.position,
        width: 36,
        height: 36,
        child: GestureDetector(
          onTap: () => _showHotspotDetail(h),
          child: Container(
            decoration: BoxDecoration(
              color: _secondary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: _secondary.withOpacity(0.5),
                  blurRadius: 6,
                ),
              ],
            ),
            child: const Icon(Icons.local_fire_department,
                color: Colors.white, size: 16),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(30),
        shadowColor: Colors.black26,
        child: TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            hintText: 'Rechercher un lieu ou une espèce...',
            hintStyle:
                GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
            prefixIcon:
                const Icon(Icons.search, color: _primary, size: 20),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = _filters[i];
          final isSelected = _activeFilter == f;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? _primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                f,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapButton(IconData icon,
      {Color color = Colors.white, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: _primary, size: 20),
      ),
    );
  }

  Widget _buildBirdPreviewCard(Bird bird) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BirdDetailScreen(bird: bird)),
      ),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _primary.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: bird.imageUrl.isNotEmpty
                  ? Image.network(
                      bird.imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[200],
                        child: const Icon(Icons.flutter_dash,
                            color: _secondary),
                      ),
                    )
                  : Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[200],
                      child: const Icon(Icons.flutter_dash, color: _secondary),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bird.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _primary,
                    ),
                  ),
                  Text(
                    bird.scientificName,
                    style: GoogleFonts.poppins(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 13, color: _secondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          bird.location,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.grey[700]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_forward_ios,
                  size: 14, color: _primary),
            ),
          ],
        ),
      ),
    );
  }

  void _showHotspotsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: _secondary),
                  const SizedBox(width: 8),
                  Text(
                    'Hotspots eBird',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Sites ornithologiques les plus actifs',
                style: GoogleFonts.poppins(
                    color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 16),
              ..._hotspots.map((h) => _HotspotTile(
                    hotspot: h,
                    onTap: () {
                      Navigator.pop(context);
                      _mapController.move(h.position, 10);
                    },
                  )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showHotspotDetail(_Hotspot h) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.local_fire_department,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('${h.name} — ${h.speciesCount} espèces signalées',
                style: GoogleFonts.poppins(fontSize: 13)),
          ],
        ),
        backgroundColor: _primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _HotspotTile extends StatelessWidget {
  final _Hotspot hotspot;
  final VoidCallback onTap;

  static const _primary = Color(0xFF624C54);
  static const _secondary = Color(0xFF90CDC6);

  const _HotspotTile({required this.hotspot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _secondary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.local_fire_department,
                  color: _secondary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotspot.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: _primary,
                    ),
                  ),
                  Text(
                    '${hotspot.speciesCount} espèces signalées',
                    style: GoogleFonts.poppins(
                        color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

class _Hotspot {
  final String name;
  final LatLng position;
  final int speciesCount;
  const _Hotspot(this.name, this.position, this.speciesCount);
}
