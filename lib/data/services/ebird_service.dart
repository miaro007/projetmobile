import 'dart:convert';
import 'package:http/http.dart' as http;

class EBirdService {
  final String _baseUrl = 'https://api.ebird.org/v2';
  final String _apiKey;

  EBirdService({required String apiKey}) : _apiKey = apiKey;

  Future<List<dynamic>> getNearbyObservations(double lat, double lng) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/data/obs/geo/recent?lat=$lat&lng=$lng'),
      headers: {'X-eBirdApiToken': _apiKey},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur eBird Observations: ${response.statusCode}');
    }
  }

  /// Récupère les Hotspots à proximité (F17)
  Future<List<dynamic>> getNearbyHotspots(double lat, double lng, {int dist = 50}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/ref/hotspot/geo?lat=$lat&lng=$lng&dist=$dist&fmt=json'),
      headers: {'X-eBirdApiToken': _apiKey},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur eBird Hotspots: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getSpeciesInfo(String speciesCode) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/ref/taxonomy/ebird?fmt=json&species=$speciesCode'),
      headers: {'X-eBirdApiToken': _apiKey},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data.isNotEmpty ? data[0] : {};
    } else {
      throw Exception('Erreur Taxonomie: ${response.statusCode}');
    }
  }
}
