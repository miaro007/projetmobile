import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/bird.dart';
import '../../data/services/ai_identification_service.dart';
import '../bloc/bird_bloc.dart';
import '../bloc/bird_event.dart';

class AddBirdScreen extends StatefulWidget {
  final String? initialSpecies;
  const AddBirdScreen({super.key, this.initialSpecies});

  @override
  State<AddBirdScreen> createState() => _AddBirdScreenState();
}

class _AddBirdScreenState extends State<AddBirdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aiService = AIIdentificationService();
  final _picker = ImagePicker();
  
  late TextEditingController _nameController;
  final _scientificNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _countController = TextEditingController(text: '1');
  
  XFile? _selectedImage;
  bool _isIdentifying = false;

  String _selectedGender = 'Indéterminé';
  String _selectedAge = 'Adulte';
  String _selectedBehavior = 'Posé';
  String _selectedHabitat = 'Forêt';
  ConservationStatus _selectedStatus = ConservationStatus.lc;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialSpecies);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scientificNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _countController.dispose();
    super.dispose();
  }

  Future<void> _pickAndIdentifyImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    setState(() {
      _selectedImage = image;
      _isIdentifying = true;
    });

    try {
      final results = await _aiService.identifyBird(image);
      if (results.isNotEmpty) {
        final bestMatch = results.first;
        setState(() {
          _nameController.text = bestMatch.label;
          // Simulation : on pourrait remplir plus de champs ici
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('IA : Identifié comme ${bestMatch.label} (${(bestMatch.confidence * 100).toStringAsFixed(0)}%)'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'identification IA'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isIdentifying = false);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newBird = Bird(
        id: const Uuid().v4(),
        name: _nameController.text,
        scientificName: _scientificNameController.text.isEmpty ? 'Inconnu' : _scientificNameController.text,
        species: 'Espèce',
        description: _descriptionController.text,
        imageUrl: _selectedImage?.path ?? 'https://images.unsplash.com/photo-1444464666168-49d633b867ad?q=80&w=1000&auto=format&fit=crop',
        observedAt: DateTime.now(),
        location: _locationController.text,
        count: int.tryParse(_countController.text) ?? 1,
        gender: _selectedGender,
        age: _selectedAge,
        behavior: _selectedBehavior,
        habitat: _selectedHabitat,
        status: _selectedStatus,
      );

      context.read<BirdBloc>().add(AddBird(newBird));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Observation'),
        actions: [
          TextButton(onPressed: _submitForm, child: const Text('ENREGISTRER', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _nameController,
                label: 'Nom de l\'oiseau *',
                icon: Icons.search,
                suffix: _isIdentifying ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : null,
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _locationController,
                label: 'Lieu de l\'observation *',
                icon: Icons.location_on_outlined,
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDropdown(label: 'Sexe', value: _selectedGender, items: ['Indéterminé', 'Mâle', 'Femelle'], onChanged: (v) => setState(() => _selectedGender = v!))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDropdown(label: 'Comportement', value: _selectedBehavior, items: ['Posé', 'Vol', 'Chant'], onChanged: (v) => setState(() => _selectedBehavior = v!))),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(controller: _descriptionController, label: 'Notes', icon: Icons.notes, maxLines: 3),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: _pickAndIdentifyImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
          image: _selectedImage != null ? DecorationImage(image: FileImage(File(_selectedImage!.path)), fit: BoxFit.cover) : null,
        ),
        child: _selectedImage == null 
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, size: 40, color: Colors.green),
                const SizedBox(height: 8),
                const Text('Identifier avec l\'IA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                Text('Prenez une photo pour une aide auto', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            )
          : null,
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, Widget? suffix, int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdown({required String label, required String value, required List<String> items, required Function(String?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
