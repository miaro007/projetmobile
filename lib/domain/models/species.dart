import 'package:equatable/equatable.dart';
import 'bird.dart';

class Species extends Equatable {
  final String id;
  final String commonName;
  final String scientificName;
  final String family;
  final String order;
  final String description;
  final List<String> imageUrls;
  final String audioUrl;
  final String size; // e.g., "15-25cm"
  final String weight;
  final String plumage;
  final String habitat;
  final String food;
  final String reproduction;
  final ConservationStatus status;
  final List<String> similarSpeciesIds;

  const Species({
    required this.id,
    required this.commonName,
    required this.scientificName,
    required this.family,
    required this.order,
    required this.description,
    required this.imageUrls,
    required this.audioUrl,
    required this.size,
    required this.weight,
    required this.plumage,
    required this.habitat,
    required this.food,
    required this.reproduction,
    required this.status,
    this.similarSpeciesIds = const [],
  });

  @override
  List<Object?> get props => [id, commonName, scientificName, family];
}
