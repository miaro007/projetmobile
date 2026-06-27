import 'package:equatable/equatable.dart';
import '../../domain/models/bird.dart';

abstract class BirdState extends Equatable {
  const BirdState();
  
  @override
  List<Object> get props => [];
}

class BirdInitial extends BirdState {}

class BirdLoading extends BirdState {}

class BirdsLoaded extends BirdState {
  final List<Bird> birds;
  const BirdsLoaded(this.birds);

  @override
  List<Object> get props => [birds];
}

class BirdError extends BirdState {
  final String message;
  const BirdError(this.message);

  @override
  List<Object> get props => [message];
}
