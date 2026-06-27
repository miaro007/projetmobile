import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/species_repository.dart';
import 'species_event.dart';
import 'species_state.dart';

class SpeciesBloc extends Bloc<SpeciesEvent, SpeciesState> {
  final SpeciesRepository speciesRepository;

  SpeciesBloc({required this.speciesRepository}) : super(SpeciesInitial()) {
    on<LoadAllSpecies>(_onLoadAllSpecies);
    on<SearchSpecies>(_onSearchSpecies);
    on<FilterSpecies>(_onFilterSpecies);
  }

  Future<void> _onLoadAllSpecies(LoadAllSpecies event, Emitter<SpeciesState> emit) async {
    emit(SpeciesLoading());
    try {
      final species = await speciesRepository.getAllSpecies();
      emit(SpeciesLoaded(species: species, filteredSpecies: species));
    } catch (e) {
      emit(SpeciesError(e.toString()));
    }
  }

  Future<void> _onSearchSpecies(SearchSpecies event, Emitter<SpeciesState> emit) async {
    final currentState = state;
    if (currentState is SpeciesLoaded) {
      if (event.query.isEmpty) {
        emit(currentState.copyWith(filteredSpecies: currentState.species, searchQuery: ''));
        return;
      }
      final results = await speciesRepository.searchSpecies(event.query);
      emit(currentState.copyWith(filteredSpecies: results, searchQuery: event.query));
    }
  }

  Future<void> _onFilterSpecies(FilterSpecies event, Emitter<SpeciesState> emit) async {
    final currentState = state;
    if (currentState is SpeciesLoaded) {
      emit(SpeciesLoading());
      try {
        final results = await speciesRepository.filterSpecies(
          habitat: event.habitat,
          size: event.size,
        );
        emit(currentState.copyWith(filteredSpecies: results));
      } catch (e) {
        emit(SpeciesError(e.toString()));
      }
    }
  }
}
