import 'package:equatable/equatable.dart';
import '../../../domain/models/species.dart';

abstract class SpeciesState extends Equatable {
  const SpeciesState();

  @override
  List<Object?> get props => [];
}

class SpeciesInitial extends SpeciesState {}

class SpeciesLoading extends SpeciesState {}

class SpeciesLoaded extends SpeciesState {
  final List<Species> species;
  final List<Species> filteredSpecies;
  final String? searchQuery;

  const SpeciesLoaded({
    required this.species,
    this.filteredSpecies = const [],
    this.searchQuery,
  });

  @override
  List<Object?> get props => [species, filteredSpecies, searchQuery];

  SpeciesLoaded copyWith({
    List<Species>? species,
    List<Species>? filteredSpecies,
    String? searchQuery,
  }) {
    return SpeciesLoaded(
      species: species ?? this.species,
      filteredSpecies: filteredSpecies ?? this.filteredSpecies,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class SpeciesError extends SpeciesState {
  final String message;
  const SpeciesError(this.message);

  @override
  List<Object?> get props => [message];
}
