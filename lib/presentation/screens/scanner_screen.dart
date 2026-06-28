import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:record/record.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:image_picker/image_picker.dart';
import '../widgets/futuristic_scanner_overlay.dart';
import 'analysis_loading_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  static const _primary = Color(0xFF624C54);
  static const _secondary = Color(0xFF90CDC6);
  static const _tertiary = Color(0xFFF6C69D);

  CameraController? _cameraController;
  final AudioRecorder _audioRecorder = AudioRecorder();
  
  bool _isCameraInitialized = false;
  bool _isAudioMode = false;
  bool _isRecording = false;

  final ImagePicker _imagePicker = ImagePicker();

  late AnimationController _scanAnimationController;

  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _initCamera();
  }

  Future<void> _initCamera() async {
    if (kIsWeb) {
      // Pour le test web, on ne lance pas la vraie caméra pour éviter les bugs
      // On affichera un fond noir
      setState(() {
        _isCameraInitialized = false;
      });
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Erreur d\'initialisation de la caméra: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _audioRecorder.dispose();
    _scanAnimationController.dispose();
    super.dispose();
  }

  Future<void> _captureOrRecord() async {
    if (_isAudioMode) {
      if (_isRecording) {
        await _audioRecorder.stop();
        setState(() => _isRecording = false);
        _goToAnalysis();
      } else {
        if (await _audioRecorder.hasPermission()) {
          await _audioRecorder.start(const RecordConfig(), path: '');
          setState(() => _isRecording = true);
        }
      }
    } else {
      // Photo Mode
      if (_isCameraInitialized && _cameraController != null) {
        try {
          await _cameraController!.takePicture();
          _goToAnalysis();
        } catch (e) {
          debugPrint('Erreur capture: $e');
          _goToAnalysis(); // On passe quand même à l'analyse (mock)
        }
      } else {
        // Mode Web ou Caméra indisponible
        _goToAnalysis();
      }
    }
  }

  void _goToAnalysis() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisLoadingScreen(isAudio: _isAudioMode),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        // Lancer l'analyse avec la photo sélectionnée
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AnalysisLoadingScreen(isAudio: false),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible d\'accéder à la galerie',
                style: GoogleFonts.poppins(fontSize: 13)),
            backgroundColor: const Color(0xFF624C54),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Fond : Caméra en direct ou fond noir
          if (_isCameraInitialized && _cameraController != null)
            SizedBox.expand(
              child: CameraPreview(_cameraController!),
            )
          else
            const Center(
              child: Icon(Icons.videocam_off, color: Colors.white24, size: 80),
            ),

          // 2. Overlay Scanner Futuriste
          FuturisticScannerOverlay(
            scanLineAnimation: _scanAnimationController,
            isRecordingAudio: _isRecording,
          ),

          // 3. UI Superposée (Boutons, Textes)
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _secondary.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isAudioMode ? Icons.mic : Icons.camera_alt,
                              color: _secondary,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isAudioMode ? 'MODE AUDIO' : 'MODE PHOTO',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 40), // Pour centrer le badge
                    ],
                  ),
                ),

                // Indication au centre si enregistrement
                if (_isRecording)
                  Container(
                    margin: const EdgeInsets.only(top: 100),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 10),
                      ],
                    ),
                    child: Text(
                      'ENREGISTREMENT...',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                const Spacer(),

                // Mode Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildModeButton('PHOTO', !_isAudioMode, () {
                      if (!_isRecording) setState(() => _isAudioMode = false);
                    }),
                    const SizedBox(width: 30),
                    _buildModeButton('AUDIO', _isAudioMode, () {
                      if (!_isRecording) setState(() => _isAudioMode = true);
                    }),
                  ],
                ),
                // Boutons bas : Galerie + Capture + Espace
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Bouton Galerie (uniquement en mode photo)
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _isAudioMode ? 0.3 : 1.0,
                        child: GestureDetector(
                          onTap: _isAudioMode ? null : _pickFromGallery,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black54,
                              border: Border.all(color: Colors.white54, width: 2),
                            ),
                            child: const Icon(
                              Icons.photo_library_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                      // Bouton Capture principal
                      GestureDetector(
                        onTap: _captureOrRecord,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _isRecording ? 80 : 70,
                          height: _isRecording ? 80 : 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isAudioMode
                                ? (_isRecording ? const Color(0xFF8B6A74) : const Color(0xFF624C54))
                                : const Color(0xFF90CDC6),
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: (_isAudioMode
                                    ? const Color(0xFF624C54)
                                    : const Color(0xFF90CDC6))
                                    .withOpacity(0.6),
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              _isAudioMode
                                  ? (_isRecording ? Icons.stop : Icons.mic)
                                  : Icons.camera_alt,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                      // Espace symétrique (vide)
                      const SizedBox(width: 50, height: 50),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? _tertiary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.white54,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
