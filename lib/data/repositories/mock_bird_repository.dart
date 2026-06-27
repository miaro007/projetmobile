import 'package:uuid/uuid.dart';
import '../../domain/models/bird.dart';
import '../../domain/repositories/bird_repository.dart';

class MockBirdRepository implements BirdRepository {
  final List<Bird> _observations = [
    Bird(
      id: '1',
      name: 'Rouge-gorge familier',
      scientificName: 'Erithacus rubecula',
      species: 'Passereau',
      description: 'Le rouge-gorge familier est une espèce d\'oiseaux de l\'ordre des Passériformes. Il est très commun en Europe et facilement reconnaissable à son plastron orangé.',
      imageUrl: 'https://images.unsplash.com/photo-1552728089-57bdde30ebd3?q=80&w=1000&auto=format&fit=crop',
      observedAt: DateTime.now().subtract(const Duration(days: 1)),
      location: 'Jardin Public, Bordeaux',
      habitat: 'Jardin',
      behavior: 'Chant',
      status: ConservationStatus.lc,
    ),
    Bird(
      id: '2',
      name: 'Mésange bleue',
      scientificName: 'Cyanistes caeruleus',
      species: 'Passereau',
      description: 'Petite mésange vive au plumage bleu et jaune. Elle est très agile et fréquente souvent les mangeoires en hiver.',
      imageUrl: 'https://images.unsplash.com/photo-1522448452220-449e7943f66a?q=80&w=1000&auto=format&fit=crop',
      observedAt: DateTime.now().subtract(const Duration(hours: 5)),
      location: 'Forêt de pins',
      habitat: 'Forêt',
      behavior: 'Alimentation',
      status: ConservationStatus.lc,
    ),
    Bird(
      id: '3',
      name: 'Martin-pêcheur d\'Europe',
      scientificName: 'Alcedo atthis',
      species: 'Coraciiformes',
      description: 'Oiseau aux couleurs éclatantes, bleu turquoise et orangé. Il plonge de manière spectaculaire pour capturer des poissons.',
      imageUrl: 'https://images.unsplash.com/photo-1539243360452-4127539a6745?q=80&w=1000&auto=format&fit=crop',
      observedAt: DateTime.now().subtract(const Duration(days: 3)),
      location: 'Bord de rivière',
      habitat: 'Zone humide',
      behavior: 'Chasse',
      status: ConservationStatus.lc,
    ),
  ];

  @override
  Future<List<Bird>> getObservations() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return List.unmodifiable(_observations);
  }

  @override
  Future<void> addObservation(Bird bird) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _observations.insert(0, bird);
  }
}
