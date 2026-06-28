import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqService {
  static const String _apiKey = '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';
  static const String _chatEndpoint = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _audioEndpoint = 'https://api.groq.com/openai/v1/audio/transcriptions';
  
  static const String _systemPrompt = 
      "Tu es un expert ornithologue virtuel nommé 'Akany Bot', conçu spécialement pour l'application d'observation d'oiseaux Akany. "
      "Tu réponds toujours en français. Tes réponses doivent être concises, informatives, passionnées et sympathiques. "
      "Si on te pose une question qui n'est pas liée aux oiseaux, à la nature ou à l'ornithologie, rappelle poliment que tu es spécialisé dans l'ornithologie.";

  /// Envoie un message avec l'historique et retourne la réponse de l'IA
  Future<String> sendMessage(List<Map<String, String>> messages) async {
    try {
      // Préparation de la requête avec le prompt système
      final List<Map<String, String>> apiMessages = [
        {'role': 'system', 'content': _systemPrompt},
        ...messages,
      ];

      final response = await http.post(
        Uri.parse(_chatEndpoint),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': apiMessages,
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'].toString().trim();
      } else {
        final errorData = jsonDecode(response.body);
        return "Erreur du serveur : ${errorData['error']['message']}";
      }
    } catch (e) {
      return "Une erreur de connexion est survenue. Vérifiez votre réseau.";
    }
  }

  /// Transcrit un fichier audio en texte via Groq Whisper API (Utilisant un chemin)
  Future<String?> transcribeAudio(String filePath) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_audioEndpoint));
      request.headers['Authorization'] = 'Bearer $_apiKey';
      request.fields['model'] = 'whisper-large-v3-turbo';
      request.fields['language'] = 'fr';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['text']?.toString().trim();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Transcrit un audio depuis des bytes (Idéal pour le Web)
  Future<String?> transcribeAudioBytes(List<int> bytes, String filename) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_audioEndpoint));
      request.headers['Authorization'] = 'Bearer $_apiKey';
      request.fields['model'] = 'whisper-large-v3-turbo';
      request.fields['language'] = 'fr';
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['text']?.toString().trim();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
