import 'dart:convert';
import 'package:http/http.dart' as http;

class XenoCantoService {
  final String apiKey;
  final String _baseUrl = 'https://xeno-canto.org/api/2/recordings';

  XenoCantoService({required this.apiKey});

  Future<String?> getAudioUrl(String scientificName) async {
    try {
      // Nettoyer le nom scientifique pour la recherche (enlever les sous-espèces etc si nécessaire)
      final query = Uri.encodeComponent(scientificName);
      final uri = Uri.parse('$_baseUrl?query=$query');
      
      final response = await http.get(
        uri,
        headers: {
          // Bien que l'API v2 soit ouverte, nous passons la clé comme demandé
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['recordings'] != null && data['recordings'].isNotEmpty) {
          // Prendre le premier enregistrement (généralement de bonne qualité)
          String fileUrl = data['recordings'][0]['file'];
          if (fileUrl.startsWith('//')) {
            fileUrl = 'https:$fileUrl';
          }
          return fileUrl;
        }
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération audio Xeno-Canto: $e');
      return null;
    }
  }
}
