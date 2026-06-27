import '../models/species.dart';

abstract class SpeciesRepository {
  Future<List<Species>> getAllSpecies();
  Future<List<Species>> searchSpecies(String query);
  Future<List<Species>> filterSpecies({
    String? habitat,
    String? size,
    List<String>? colors,
  });
  Future<Species?> getSpeciesById(String id);
}
