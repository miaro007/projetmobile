import '../../domain/models/hotspot.dart';
import '../../domain/repositories/hotspot_repository.dart';
import '../services/ebird_service.dart';

class HotspotRepositoryImpl implements HotspotRepository {
  final EBirdService eBirdService;

  HotspotRepositoryImpl({required this.eBirdService});

  @override
  Future<List<Hotspot>> getNearbyHotspots(double lat, double lng) async {
    try {
      final data = await eBirdService.getNearbyHotspots(lat, lng);
      return data.map((item) => Hotspot(
        id: item['locId'],
        name: item['locName'],
        latitude: item['lat'].toDouble(),
        longitude: item['lng'].toDouble(),
        countryCode: item['countryCode'],
        subnational1Code: item['subnational1Code'],
        latestObsAt: item['latestObsDt'] != null ? DateTime.tryParse(item['latestObsDt']) : null,
        numSpeciesAllTime: item['numSpeciesAllTime'],
      )).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des hotspots: $e');
    }
  }
}
