import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class SupabaseStorageService {
  final _supabase = Supabase.instance.client;
  
  Future<String?> uploadPhoto(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      
      String fileExtension = '.jpg';
      if (imageFile.name.contains('.')) {
        fileExtension = '.${imageFile.name.split('.').last}';
      }
      
      final fileName = '${const Uuid().v4()}$fileExtension';
      final filePath = 'observations/$fileName';
      
      await _supabase.storage.from('photos').uploadBinary(
        filePath,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );
      
      final publicUrl = _supabase.storage.from('photos').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print('Erreur upload photo: $e');
      return null;
    }
  }
}
