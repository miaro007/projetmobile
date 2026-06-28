import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/species/species_bloc.dart';
import '../../bloc/species/species_event.dart';
import '../../bloc/species/species_state.dart';
import 'species_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SpeciesListScreen extends StatefulWidget {
  const SpeciesListScreen({super.key});

  @override
  State<SpeciesListScreen> createState() => _SpeciesListScreenState();
}

class _SpeciesListScreenState extends State<SpeciesListScreen> {
  String _selectedSize = 'Toutes';
  String _selectedHabitat = 'Tous';

  final List<String> _sizes = [
    'Toutes',
    'Très petit (<15cm)',
    'Petit (15-25cm)',
    'Moyen (25-40cm)',
    'Grand (40-60cm)',
    'Très grand (>60cm)'
  ];

  final List<String> _habitats = [
    'Tous',
    'Forêt',
    'Prairie',
    'Zone humide',
    'Littoral',
    'Montagne',
    'Urbain'
  ];

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Identifier par critères',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text('Taille', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: _sizes.map((size) {
                      final isSelected = _selectedSize == size;
                      return ChoiceChip(
                        label: Text(size, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black)),
                        selected: isSelected,
                        selectedColor: Colors.green,
                        onSelected: (selected) {
                          setSheetState(() => _selectedSize = size);
                          setState(() {});
                          context.read<SpeciesBloc>().add(FilterSpecies(
                            size: _selectedSize,
                            habitat: _selectedHabitat,
                          ));
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text('Habitat', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: _habitats.map((habitat) {
                      final isSelected = _selectedHabitat == habitat;
                      return ChoiceChip(
                        label: Text(habitat, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black)),
                        selected: isSelected,
                        selectedColor: Colors.blue,
                        onSelected: (selected) {
                          setSheetState(() => _selectedHabitat = habitat);
                          setState(() {});
                          context.read<SpeciesBloc>().add(FilterSpecies(
                            size: _selectedSize,
                            habitat: _selectedHabitat,
                          ));
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text('APPLIQUER'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Guide des Oiseaux', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.tune),
                if (_selectedSize != 'Toutes' || _selectedHabitat != 'Tous')
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
            onPressed: _showFilterSheet,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (value) => context.read<SpeciesBloc>().add(SearchSpecies(value)),
              decoration: InputDecoration(
                hintText: 'Rechercher une espèce...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<SpeciesBloc, SpeciesState>(
        builder: (context, state) {
          if (state is SpeciesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SpeciesLoaded) {
            final list = state.filteredSpecies;
            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    const Text('Aucune espèce ne correspond à vos critères.'),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedSize = 'Toutes';
                          _selectedHabitat = 'Tous';
                        });
                        context.read<SpeciesBloc>().add(LoadAllSpecies());
                      },
                      child: const Text('Réinitialiser les filtres'),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final species = list[index];
                return SpeciesTile(species: species);
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class SpeciesTile extends StatelessWidget {
  final dynamic species;

  const SpeciesTile({super.key, required this.species});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SpeciesDetailScreen(species: species)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                bottomLeft: Radius.circular(11),
              ),
              child: CachedNetworkImage(
                imageUrl: species.imageUrls.isNotEmpty ? species.imageUrls[0] : '',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[100], width: 100, height: 100),
                errorWidget: (context, url, error) => Container(color: Colors.grey[200], width: 100, height: 100, child: const Icon(Icons.image_not_supported)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    species.commonName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    species.scientificName,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildBadge(species.habitat, Colors.blue),
                      const SizedBox(width: 4),
                      _buildBadge(species.size.split(' ')[0], Colors.green),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
