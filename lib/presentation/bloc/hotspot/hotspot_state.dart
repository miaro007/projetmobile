import 'package:equatable/equatable.dart';
import '../../../domain/models/hotspot.dart';

abstract class HotspotState extends Equatable {
  const HotspotState();
  
  @override
  List<Object?> get props => [];
}

class HotspotInitial extends HotspotState {}

class HotspotLoading extends HotspotState {}

class HotspotsLoaded extends HotspotState {
  final List<Hotspot> hotspots;

  const HotspotsLoaded(this.hotspots);

  @override
  List<Object?> get props => [hotspots];
}

class HotspotError extends HotspotState {
  final String message;

  const HotspotError(this.message);

  @override
  List<Object?> get props => [message];
}
