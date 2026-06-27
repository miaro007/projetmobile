import 'package:equatable/equatable.dart';

enum ConservationStatus { lc, nt, vu, en, cr, ew, ex }

class Bird extends Equatable {
  final String id;
  final String name;
  final String scientificName;
  final String species;
  final String description;
  final String imageUrl;
  final String? audioUrl;
  final DateTime observedAt;
  final String location;
  final double? latitude;
  final double? longitude;
  
  // Champs spécifiés dans le cahier des charges
  final int count;
  final String gender; // Mâle, Femelle, Inconnu
  final String age; // Adulte, Juvénile
  final String behavior; // Alimentation, Vol, Chant, etc.
  final String habitat;
  final ConservationStatus status;

  const Bird({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.species,
    required this.description,
    required this.imageUrl,
    this.audioUrl,
    required this.observedAt,
    required this.location,
    this.latitude,
    this.longitude,
    this.count = 1,
    this.gender = 'Indéterminé',
    this.age = 'Adulte',
    this.behavior = 'Posé',
    this.habitat = 'Forêt',
    this.status = ConservationStatus.lc,
  });

  @override
  List<Object?> get props => [
    id, name, scientificName, species, description, imageUrl, 
    observedAt, location, count, gender, behavior
  ];
}
