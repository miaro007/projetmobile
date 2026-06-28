import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../../domain/models/bird.dart';
import '../../domain/models/species.dart';
import 'species/species_detail_screen.dart';
import '../../data/repositories/species_repository_impl.dart';
import '../../data/services/ebird_service.dart';
import '../../data/services/nuthatch_service.dart';
import '../../data/services/wikipedia_service.dart';
import '../../data/services/xeno_canto_service.dart';

class AnalysisLoadingScreen extends StatefulWidget {
  final bool isAudio;

  const AnalysisLoadingScreen({super.key, required this.isAudio});

  @override
  State<AnalysisLoadingScreen> createState() => _AnalysisLoadingScreenState();
}

class _AnalysisLoadingScreenState extends State<AnalysisLoadingScreen>
    with SingleTickerProviderStateMixin {
  static const _primary = Color(0xFF624C54);
  static const _secondary = Color(0xFF90CDC6);
  
  late AnimationController _pulseController;

  final List<String> _photoSteps = [
    'Analyse du plumage...',
    'Détection de la forme du bec...',
    'Recherche dans la base de données...',
    'Identification terminée !'
  ];

  final List<String> _audioSteps = [
    'Extraction des fréquences...',
    'Analyse du spectrogramme...',
    'Comparaison avec Xeno-Canto...',
    'Correspondance trouvée !'
  ];

  int _currentStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    final steps = widget.isAudio ? _audioSteps : _photoSteps;

    for (int i = 0; i < steps.length - 1; i++) {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() {
          _currentStepIndex = i + 1;
        });
      }
    }
    
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (mounted) {
      // On instancie temporairement le repository pour récupérer un oiseau aléatoire
      final repository = SpeciesRepositoryImpl(
        eBirdService: EBirdService(apiKey: 'dummy'),
        nuthatchService: NuthatchService(),
        wikipediaService: WikipediaService(),
        xenoCantoService: XenoCantoService(apiKey: 'dummy'),
      );

      final speciesList = await repository.getAllSpecies();
      
      late Species detectedSpecies;
      if (speciesList.isNotEmpty) {
        detectedSpecies = speciesList[Random().nextInt(speciesList.length)];
      } else {
        // Fallback
        detectedSpecies = Species(
          id: 'mock_1',
          commonName: 'Oiseau inconnu',
          scientificName: 'Aves',
          order: '',
          family: '',
          description: 'L\'oiseau n\'a pas pu être identifié.',
          plumage: '',
          habitat: '',
          food: '',
          reproduction: '',
          size: '',
          weight: '',
          status: ConservationStatus.lc,
          imageUrls: [],
          audioUrl: '',
        );
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SpeciesDetailScreen(species: detectedSpecies),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.isAudio ? _audioSteps : _photoSteps;
    final currentText = steps[_currentStepIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Mode sombre pour effet futuriste
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animation de scan circulaire
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _secondary.withOpacity(0.5 + (_pulseController.value * 0.5)),
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _secondary.withOpacity(_pulseController.value * 0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      widget.isAudio ? Icons.graphic_eq : Icons.camera_alt,
                      color: _secondary,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 50),
            // Texte dynamique
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                currentText,
                key: ValueKey<String>(currentText),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              width: 150,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(_secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
