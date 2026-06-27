import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/bird_repository.dart';
import 'bird_event.dart';
import 'bird_state.dart';

class BirdBloc extends Bloc<BirdEvent, BirdState> {
  final BirdRepository birdRepository;

  BirdBloc({required this.birdRepository}) : super(BirdInitial()) {
    on<LoadBirds>(_onLoadBirds);
    on<AddBird>(_onAddBird);
  }

  Future<void> _onLoadBirds(LoadBirds event, Emitter<BirdState> emit) async {
    emit(BirdLoading());
    try {
      final birds = await birdRepository.getObservations();
      emit(BirdsLoaded(birds));
    } catch (e) {
      emit(BirdError(e.toString()));
    }
  }

  Future<void> _onAddBird(AddBird event, Emitter<BirdState> emit) async {
    try {
      await birdRepository.addObservation(event.bird);
      add(LoadBirds()); // Reload list
    } catch (e) {
      emit(BirdError(e.toString()));
    }
  }
}
