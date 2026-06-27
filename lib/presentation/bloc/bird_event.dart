import 'package:equatable/equatable.dart';
import '../../domain/models/bird.dart';

abstract class BirdEvent extends Equatable {
  const BirdEvent();

  @override
  List<Object> get props => [];
}

class LoadBirds extends BirdEvent {}

class AddBird extends BirdEvent {
  final Bird bird;
  const AddBird(this.bird);

  @override
  List<Object> get props => [bird];
}
