import 'package:flutter/foundation.dart';
import '../../domain/models/bird.dart';
import '../../domain/models/species.dart';
import '../../domain/repositories/species_repository.dart';
import '../services/ebird_service.dart';
import '../services/wikipedia_service.dart';
import '../services/nuthatch_service.dart';

class SpeciesRepositoryImpl implements SpeciesRepository {
  final EBirdService eBirdService;
  final WikipediaService wikipediaService;
  final NuthatchService nuthatchService;

  SpeciesRepositoryImpl({
    required this.eBirdService,
    required this.wikipediaService,
    required this.nuthatchService,
  });

  @override
  Future<List<Species>> getAllSpecies() async {
    // Utiliser l'API Nuthatch gratuite pour récupérer les espèces
    try {
      final birds = await nuthatchService.getBirds(limit: 50);
      return birds.map((bird) => _mapToSpecies(bird)).toList();
    } catch (e) {
      debugPrint('Error fetching species from Nuthatch: $e');
      // Fallback to simulation if API fails
      return searchSpecies('');
    }
  }

  @override
  Future<List<Species>> searchSpecies(String query) async {
    try {
      if (query.isEmpty) {
        return getAllSpecies();
      }
      final birds = await nuthatchService.searchBirds(query);
      return birds.map((bird) => _mapToSpecies(bird)).toList();
    } catch (e) {
      debugPrint('Error searching species: $e');
      // Fallback simulation
      final List<Species> results = [];
      final names = ['Rouge-gorge familier', 'Mésange bleue', 'Pinson des arbres'];
      final scientificNames = ['Erithacus rubecula', 'Cyanistes caeruleus', 'Fringilla coelebs'];

      for (int i = 0; i < scientificNames.length; i++) {
        if (query.isEmpty || names[i].toLowerCase().contains(query.toLowerCase())) {
          final wikiData = await wikipediaService.getBirdDetails(scientificNames[i]);
          
          results.add(Species(
            id: 'api_$i',
            commonName: names[i],
            scientificName: scientificNames[i],
            family: 'Inconnue',
            order: 'Passeriformes',
            description: wikiData['description'] ?? '',
            imageUrls: [wikiData['imageUrl'] ?? ''],
            audioUrl: '',
            size: '--',
            weight: '--',
            plumage: 'Voir description',
            habitat: 'Divers',
            food: 'Omnivore',
            reproduction: 'Saisonnier',
            status: ConservationStatus.lc,
          ));
        }
      }
      return results;
    }
  }

  Species _mapToSpecies(dynamic bird) {
    final images = bird['images'] as List<dynamic>? ?? [];
    final imageUrl = images.isNotEmpty ? images[0].toString() : '';
    
    return Species(
      id: bird['uid']?.toString() ?? '',
      commonName: bird['name']?.toString() ?? 'Unknown',
      scientificName: bird['sciName']?.toString() ?? '',
      family: bird['family']?.toString() ?? '',
      order: bird['order']?.toString() ?? '',
      description: bird['brief']?.toString() ?? '',
      imageUrls: [imageUrl],
      audioUrl: '',
      size: '--',
      weight: '--',
      plumage: 'Voir description',
      habitat: 'Divers',
      food: 'Omnivore',
      reproduction: 'Saisonnier',
      status: ConservationStatus.lc,
    );
  }

  @override
  Future<List<Species>> filterSpecies({String? habitat, String? size, List<String>? colors}) async {
    return getAllSpecies();
  }

  @override
  Future<Species?> getSpeciesById(String id) async => null;
}
