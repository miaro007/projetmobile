import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/hotspot_repository.dart';
import 'hotspot_event.dart';
import 'hotspot_state.dart';

class HotspotBloc extends Bloc<HotspotEvent, HotspotState> {
  final HotspotRepository hotspotRepository;

  HotspotBloc({required this.hotspotRepository}) : super(HotspotInitial()) {
    on<LoadNearbyHotspots>(_onLoadNearbyHotspots);
  }

  Future<void> _onLoadNearbyHotspots(
    LoadNearbyHotspots event,
    Emitter<HotspotState> emit,
  ) async {
    emit(HotspotLoading());
    try {
      final hotspots = await hotspotRepository.getNearbyHotspots(
        event.latitude,
        event.longitude,
      );
      emit(HotspotsLoaded(hotspots));
    } catch (e) {
      emit(HotspotError(e.toString()));
    }
  }
}
