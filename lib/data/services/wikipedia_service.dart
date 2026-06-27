import 'dart:convert';
import 'package:http/http.dart' as http;

class WikipediaService {
  Future<Map<String, String>> getBirdDetails(String scientificName) async {
    final url = 'https://fr.wikipedia.org/api/rest_v1/page/summary/${scientificName.replaceAll(' ', '_')}';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'description': data['extract'] ?? 'Aucune description disponible.',
          'imageUrl': data['originalimage']?['source'] ?? '',
        };
      }
    } catch (e) {
      print('Erreur Wikipedia: $e');
    }
    return {'description': '', 'imageUrl': ''};
  }
}
