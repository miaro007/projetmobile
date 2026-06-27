import 'dart:convert';
import 'package:http/http.dart' as http;

class NuthatchService {
  final String _baseUrl = 'https://api.nuthatch.lastelm.software/v2';

  /// Récupère la liste des oiseaux avec filtres optionnels
  Future<List<dynamic>> getBirds({
    String? family,
    bool hasImg = true,
    int limit = 50,
  }) async {
    String url = '$_baseUrl/birds?hasImg=$hasImg&limit=$limit';
    if (family != null) {
      url += '&family=$family';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['entities'] ?? [];
    } else {
      throw Exception('Erreur Nuthatch API: ${response.statusCode}');
    }
  }

  /// Récupère les informations d'un oiseau spécifique par son nom scientifique
  Future<Map<String, dynamic>> getBirdBySciName(String sciName) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/birds?sciName=$sciName'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final entities = data['entities'] ?? [];
      return entities.isNotEmpty ? entities[0] : {};
    } else {
      throw Exception('Erreur Nuthatch API: ${response.statusCode}');
    }
  }

  /// Récupère les familles d'oiseaux disponibles
  Future<List<String>> getFamilies() async {
    // Cette méthode peut être étendue si l'API fournit un endpoint pour les familles
    // Pour l'instant, nous retournons une liste de familles courantes
    return [
      'Troglodytidae',
      'Parulidae',
      'Turdidae',
      'Fringillidae',
      'Corvidae',
      'Sturnidae',
      'Mimidae',
      'Icteridae',
      'Cardinalidae',
    ];
  }

  /// Recherche d'oiseaux par nom
  Future<List<dynamic>> searchBirds(String query) async {
    final birds = await getBirds(limit: 100);
    return birds.where((bird) {
      final name = bird['name']?.toString().toLowerCase() ?? '';
      final sciName = bird['sciName']?.toString().toLowerCase() ?? '';
      return name.contains(query.toLowerCase()) || 
             sciName.contains(query.toLowerCase());
    }).toList();
  }
}
