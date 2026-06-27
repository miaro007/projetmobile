import 'package:equatable/equatable.dart';

abstract class SpeciesEvent extends Equatable {
  const SpeciesEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllSpecies extends SpeciesEvent {}

class SearchSpecies extends SpeciesEvent {
  final String query;
  const SearchSpecies(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterSpecies extends SpeciesEvent {
  final String? habitat;
  final String? size;
  const FilterSpecies({this.habitat, this.size});

  @override
  List<Object?> get props => [habitat, size];
}
