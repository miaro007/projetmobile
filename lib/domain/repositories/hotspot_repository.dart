import '../models/hotspot.dart';

abstract class HotspotRepository {
  Future<List<Hotspot>> getNearbyHotspots(double lat, double lng);
}
