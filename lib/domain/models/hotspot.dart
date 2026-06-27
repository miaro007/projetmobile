import 'package:equatable/equatable.dart';

class Hotspot extends Equatable {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? countryCode;
  final String? subnational1Code;
  final DateTime? latestObsAt;
  final int? numSpeciesAllTime;

  const Hotspot({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.countryCode,
    this.subnational1Code,
    this.latestObsAt,
    this.numSpeciesAllTime,
  });

  @override
  List<Object?> get props => [id, name, latitude, longitude];
}
