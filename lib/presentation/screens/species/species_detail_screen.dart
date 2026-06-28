import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../domain/models/bird.dart';
import '../../../domain/models/species.dart';
import '../add_bird_screen.dart';

class SpeciesDetailScreen extends StatefulWidget {
  final Species species;

  const SpeciesDetailScreen({super.key, required this.species});

  @override
  State<SpeciesDetailScreen> createState() => _SpeciesDetailScreenState();
}

class _SpeciesDetailScreenState extends State<SpeciesDetailScreen> {
  static const _primary = Color(0xFF624C54);
  static const _secondary = Color(0xFF90CDC6);
  static const _tertiary = Color(0xFFF6C69D);
  static const _bg = Color(0xFFEFEAE4);

  // Galerie
  int _currentImageIndex = 0;
  final PageController _imagePageCtrl = PageController();

  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupAudioListeners();
  }

  void _setupAudioListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playerState = state);
    });
    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _audioDuration = d);
    });
    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _audioPosition = p);
    });
  }

  @override
  void dispose() {
    _imagePageCtrl.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    final audioUrl = widget.species.audioUrl;
    if (audioUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aucun enregistrement audio disponible',
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: _primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (_playerState == PlayerState.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(audioUrl));
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageIndicators(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildAudioPlayer(),
                      const SizedBox(height: 20),
                      _buildInfoGrid(),
                      const SizedBox(height: 20),
                      _buildSection('Description', widget.species.description),
                      _buildSection('Plumage', widget.species.plumage),
                      _buildSection('Habitat', widget.species.habitat),
                      _buildSection('Alimentation', widget.species.food),
                      _buildSection('Reproduction', widget.species.reproduction),
                      const SizedBox(height: 20),
                      _buildAddButton(context),
                      const SizedBox(height: 50),
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

  Widget _buildSliverAppBar(BuildContext context) {
    final images = widget.species.imageUrls;
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Galerie photos
            images.isNotEmpty
                ? PageView.builder(
                    controller: _imagePageCtrl,
                    itemCount: images.length,
                    onPageChanged: (i) =>
                        setState(() => _currentImageIndex = i),
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: images[index],
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: const Color(0xFF8B6A74),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white54),
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: const Color(0xFF8B6A74),
                          child: const Icon(Icons.flutter_dash,
                              size: 60, color: Colors.white54),
                        ),
                      );
                    },
                  )
                : Container(
                    color: const Color(0xFF8B6A74),
                    child: const Icon(Icons.flutter_dash,
                        size: 80, color: Colors.white54),
                  ),
            // Gradient bas
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.6, 1.0],
                    colors: [Colors.transparent, Colors.black54],
                  ),
                ),
              ),
            ),
            // Compteur images
            if (images.length > 1)
              Positioned(
                bottom: 14,
                right: 14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentImageIndex + 1} / ${images.length}',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${widget.species.commonName} ajouté aux favoris !'),
                backgroundColor: _secondary,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Partage de la fiche en cours...'),
                backgroundColor: _primary,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildImageIndicators() {
    final images = widget.species.imageUrls;
    if (images.length <= 1) return const SizedBox.shrink();
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(images.length, (i) {
          return GestureDetector(
            onTap: () => _imagePageCtrl.animateToPage(i,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentImageIndex == i ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentImageIndex == i ? _primary : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                widget.species.commonName,
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: _primary,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildStatusBadge(widget.species.status),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.species.scientificName,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _secondary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${widget.species.order} · ${widget.species.family}',
            style: GoogleFonts.poppins(
              color: _secondary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ConservationStatus status) {
    final colors = {
      ConservationStatus.lc: _secondary,
      ConservationStatus.nt: _tertiary,
      ConservationStatus.vu: _tertiary.withOpacity(0.8),
      ConservationStatus.en: _primary.withOpacity(0.7),
      ConservationStatus.cr: _primary,
      ConservationStatus.ew: _primary,
      ConservationStatus.ex: Colors.grey[800],
    };
    final color = colors[status] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toString().split('.').last.toUpperCase(),
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAudioPlayer() {
    final isPlaying = _playerState == PlayerState.playing;
    final hasAudio = widget.species.audioUrl.isNotEmpty;
    final progress = _audioDuration.inMilliseconds > 0
        ? _audioPosition.inMilliseconds / _audioDuration.inMilliseconds
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary.withOpacity(0.08), _secondary.withOpacity(0.08)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primary.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: hasAudio ? _toggleAudio : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: hasAudio ? _primary : Colors.grey[300],
                    shape: BoxShape.circle,
                    boxShadow: hasAudio
                        ? [
                            BoxShadow(
                              color: _primary.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.music_note, size: 14, color: _primary),
                        const SizedBox(width: 4),
                        Text(
                          'Chant & Cris',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: _primary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      hasAudio
                          ? 'Xeno-Canto • Enregistrement terrain'
                          : 'Aucun audio disponible',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (hasAudio)
                Text(
                  isPlaying
                      ? _formatDuration(_audioPosition)
                      : _formatDuration(_audioDuration),
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600),
                ),
            ],
          ),
          if (hasAudio) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(_secondary),
              ),
            ),
            // Visualizer decoratif
            const SizedBox(height: 8),
            Row(
              children: List.generate(20, (i) {
                final h = isPlaying
                    ? (4.0 + (i % 5) * 4.0)
                    : 4.0;
                return Expanded(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 100 + i * 30),
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    height: h,
                    decoration: BoxDecoration(
                      color: _secondary.withOpacity(isPlaying ? 0.8 : 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          _infoTile(Icons.straighten, 'Taille', widget.species.size),
          _divider(),
          _infoTile(Icons.monitor_weight_outlined, 'Poids',
              widget.species.weight),
          _divider(),
          _infoTile(Icons.landscape, 'Habitat', widget.species.habitat),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: _secondary, size: 22),
          const SizedBox(height: 6),
          Text(label,
              style: GoogleFonts.poppins(
                  color: Colors.grey[500], fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: _primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.grey[100],
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildSection(String title, String content) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: _primary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddBirdScreen(initialSpecies: widget.species.commonName),
            ),
          );
        },
        icon: const Icon(Icons.add_a_photo),
        label: Text(
          'ENREGISTRER UNE OBSERVATION',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
          shadowColor: _primary.withOpacity(0.4),
        ),
      ),
    );
  }
}
