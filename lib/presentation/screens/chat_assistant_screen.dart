import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/services/groq_service.dart';

class ChatAssistantScreen extends StatefulWidget {
  const ChatAssistantScreen({super.key});

  @override
  State<ChatAssistantScreen> createState() => _ChatAssistantScreenState();
}

class _ChatAssistantScreenState extends State<ChatAssistantScreen> {
  static const _primary = Color(0xFF624C54);
  static const _secondary = Color(0xFF90CDC6);
  static const _bg = Color(0xFFEFEAE4);

  final GroqService _groqService = GroqService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Format des messages : {'role': 'user' ou 'assistant', 'content': 'texte'}
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isTranscribing = false;

  @override
  void initState() {
    super.initState();
    // Message de bienvenue
    _messages.add({
      'role': 'assistant',
      'content': 'Bonjour ! Je suis Akany Bot, votre expert ornithologue. Avez-vous une question sur un oiseau, son chant, son habitat ou sa migration ?'
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
    });
    
    _textController.clear();
    _scrollToBottom();

    // Appel à l'API Groq
    final response = await _groqService.sendMessage(_messages);

    if (mounted) {
      setState(() {
        _messages.add({'role': 'assistant', 'content': response});
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _toggleRecording() async {
    try {
      if (_isRecording) {
        // Arrêter l'enregistrement
        final path = await _audioRecorder.stop();
        setState(() {
          _isRecording = false;
          _isTranscribing = true;
        });

        if (path != null) {
          String? transcribedText;
          if (kIsWeb) {
            // Sur le web, le path est une URL blob
            final response = await http.get(Uri.parse(path));
            transcribedText = await _groqService.transcribeAudioBytes(response.bodyBytes, 'audio.m4a');
          } else {
            // Sur mobile/desktop, c'est un chemin local
            transcribedText = await _groqService.transcribeAudio(path);
          }

          if (mounted && transcribedText != null && transcribedText.isNotEmpty) {
            // Ajouter le texte dans le champ de saisie
            final currentText = _textController.text;
            _textController.text = currentText.isEmpty 
                ? transcribedText 
                : '$currentText $transcribedText';
          }
        }
        
        if (mounted) {
          setState(() {
            _isTranscribing = false;
          });
        }
      } else {
        // Démarrer l'enregistrement
        if (await _audioRecorder.hasPermission()) {
          String? path;
          if (!kIsWeb) {
            final directory = await getApplicationDocumentsDirectory();
            path = '${directory.path}/chat_dictation.m4a';
          }
          
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.aacLc),
            path: path ?? '',
          );
          setState(() {
            _isRecording = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Erreur d\'enregistrement: $e');
      if (mounted) {
        setState(() {
          _isRecording = false;
          _isTranscribing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: _secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(FontAwesomeIcons.robot, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Text(
              'Assistant Akany',
              style: GoogleFonts.poppins(
                color: _primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return _buildMessageBubble(msg['content']!, isUser);
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _secondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Akany Bot réfléchit...',
                      style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          if (_isTranscribing)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, right: 16.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Transcription...',
                      style: GoogleFonts.poppins(color: _secondary, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? _primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: isUser ? Colors.white : const Color(0xFF333333),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                style: GoogleFonts.poppins(fontSize: 14),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Posez votre question...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                  filled: true,
                  fillColor: _bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Bouton Micro
            GestureDetector(
              onTap: _toggleRecording,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isRecording ? Colors.redAccent : Colors.grey[200],
                  shape: BoxShape.circle,
                  boxShadow: _isRecording ? [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ] : null,
                ),
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic, 
                  color: _isRecording ? Colors.white : _primary, 
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Bouton Envoyer
            GestureDetector(
              onTap: _isLoading ? null : _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _isLoading ? Colors.grey : _secondary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isLoading ? Colors.grey : _secondary).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(FontAwesomeIcons.paperPlane, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
