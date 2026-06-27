import 'package:equatable/equatable.dart';

abstract class HotspotEvent extends Equatable {
  const HotspotEvent();

  @override
  List<Object?> get props => [];
}

class LoadNearbyHotspots extends HotspotEvent {
  final double latitude;
  final double longitude;

  const LoadNearbyHotspots({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}
