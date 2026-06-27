import '../models/bird.dart';

abstract class BirdRepository {
  Future<List<Bird>> getObservations();
  Future<void> addObservation(Bird bird);
}
