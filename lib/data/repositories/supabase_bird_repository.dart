import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/bird.dart';
import '../../domain/repositories/bird_repository.dart';

class SupabaseBirdRepository implements BirdRepository {
  final _client = Supabase.instance.client;

  static final List<Bird> _mockBirds = [
    Bird(
      id: 'mock-1',
      name: 'Rouge-gorge familier',
      scientificName: 'Erithacus rubecula',
      species: 'Passereau',
      description: 'Petit passereau rondelet, gorge orangée, très familier des jardins.',
      imageUrl: 'https://images.unsplash.com/photo-1551085254-e96b210db58a?q=80&w=300',
      observedAt: DateTime.now().subtract(const Duration(hours: 2)),
      location: 'Jardin Public, Bordeaux',
      count: 1,
      gender: 'Mâle',
      age: 'Adulte',
      behavior: 'Chant',
      habitat: 'Jardin',
    ),
    Bird(
      id: 'mock-2',
      name: 'Mésange bleue',
      scientificName: 'Cyanistes caeruleus',
      species: 'Passereau',
      description: 'Petite mésange vive et acrobate, calotte bleue et poitrine jaune.',
      imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?q=80&w=300',
      observedAt: DateTime.now().subtract(const Duration(days: 1)),
      location: 'Parc des Ecureuils',
      count: 2,
      gender: 'Indéterminé',
      age: 'Adulte',
      behavior: 'Alimentation',
      habitat: 'Forêt',
    ),
  ];

  @override
  Future<List<Bird>> getObservations() async {
    try {
      final response = await _client
          .from('observations')
          .select()
          .order('observed_at', ascending: false);
      
      return (response as List).map((data) => _mapToBird(data)).toList();
    } catch (e) {
      return _mockBirds;
    }
  }

  @override
  Future<void> addObservation(Bird bird) async {
    try {
      await _client.from('observations').insert(_mapFromBird(bird));
    } catch (e) {
      _mockBirds.insert(0, bird);
    }
  }

  Bird _mapToBird(Map<String, dynamic> data) {
    return Bird(
      id: data['id'],
      name: data['name'],
      scientificName: data['scientific_name'],
      species: data['species'],
      description: data['description'],
      imageUrl: data['image_url'],
      audioUrl: data['audio_url'],
      observedAt: DateTime.parse(data['observed_at']),
      location: data['location'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      count: data['count'],
      gender: data['gender'],
      age: data['age'],
      behavior: data['behavior'],
      habitat: data['habitat'],
      status: ConservationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => ConservationStatus.lc,
      ),
    );
  }

  Map<String, dynamic> _mapFromBird(Bird bird) {
    return {
      'id': bird.id,
      'name': bird.name,
      'scientific_name': bird.scientificName,
      'species': bird.species,
      'description': bird.description,
      'image_url': bird.imageUrl,
      'audio_url': bird.audioUrl,
      'observed_at': bird.observedAt.toIso8601String(),
      'location': bird.location,
      'latitude': bird.latitude,
      'longitude': bird.longitude,
      'count': bird.count,
      'gender': bird.gender,
      'age': bird.age,
      'behavior': bird.behavior,
      'habitat': bird.habitat,
      'status': bird.status.toString().split('.').last,
    };
  }
}
