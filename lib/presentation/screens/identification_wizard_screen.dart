import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/species/species_bloc.dart';
import '../bloc/species/species_event.dart';
import '../bloc/species/species_state.dart';
import 'species/species_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class IdentificationWizardScreen extends StatefulWidget {
  const IdentificationWizardScreen({super.key});

  @override
  State<IdentificationWizardScreen> createState() =>
      _IdentificationWizardScreenState();
}

class _IdentificationWizardScreenState
    extends State<IdentificationWizardScreen>
    with TickerProviderStateMixin {
  static const _primary = Color(0xFF624C54);
  static const _tertiary = Color(0xFFF6C69D);
  static const _bg = Color(0xFFEFEAE4);

  final PageController _pageCtrl = PageController();
  int _step = 0;

  String? _selectedSize;
  String? _selectedColor;
  String? _selectedHabitat;
  String? _selectedBehavior;

  late AnimationController _slideAnim;

  final List<_WizardStep> _steps = [
    _WizardStep(
      question: 'Quelle est la taille de l\'oiseau ?',
      icon: Icons.straighten,
      options: [
        _Option('Très petit', 'moins de 15 cm\n(moineau, mésange)', Icons.photo_size_select_small, 'Très petit (<15cm)'),
        _Option('Petit', '15 – 25 cm\n(rouge-gorge, merle)', Icons.photo_size_select_actual, 'Petit (15-25cm)'),
        _Option('Moyen', '25 – 40 cm\n(pigeon, colombe)', Icons.photo_size_select_large, 'Moyen (25-40cm)'),
        _Option('Grand', '40 – 60 cm\n(héron, buse)', Icons.aspect_ratio, 'Grand (40-60cm)'),
        _Option('Très grand', 'plus de 60 cm\n(cigogne, aigle)', Icons.fullscreen, 'Très grand (>60cm)'),
      ],
    ),
    _WizardStep(
      question: 'Quelle couleur domine ?',
      icon: Icons.palette,
      options: [
        _Option('Brun / Marron', '', Icons.circle, 'Brun'),
        _Option('Noir / Blanc', '', Icons.circle, 'Noir'),
        _Option('Rouge / Orange', '', Icons.circle, 'Rouge'),
        _Option('Bleu / Vert', '', Icons.circle, 'Bleu'),
        _Option('Gris', '', Icons.circle, 'Gris'),
        _Option('Jaune', '', Icons.circle, 'Jaune'),
      ],
    ),
    _WizardStep(
      question: 'Où l\'avez-vous observé ?',
      icon: Icons.landscape,
      options: [
        _Option('Forêt', 'sous-bois, arbres', Icons.park, 'Forêt'),
        _Option('Prairie', 'champs, bocage', Icons.grass, 'Prairie'),
        _Option('Zone humide', 'marais, lac, rivière', Icons.water, 'Zone humide'),
        _Option('Littoral', 'plage, falaise, mer', Icons.beach_access, 'Littoral'),
        _Option('Montagne', 'alpages, rochers', Icons.terrain, 'Montagne'),
        _Option('Urbain', 'ville, jardin, parc', Icons.location_city, 'Urbain'),
      ],
    ),
    _WizardStep(
      question: 'Que faisait-il ?',
      icon: Icons.psychology,
      options: [
        _Option('Posé', 'sur une branche, le sol', Icons.location_on, 'Posé'),
        _Option('En vol', 'planant, battant des ailes', Icons.flight, 'Vol'),
        _Option('Chantait', 'émettant des sons', Icons.music_note, 'Chant'),
        _Option('Nageait', 'sur l\'eau', Icons.pool, 'Nage'),
        _Option('Se nourrissait', 'cherchant de la nourriture', Icons.restaurant, 'Alimentation'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _slideAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _slideAnim.dispose();
    super.dispose();
  }

  void _selectOption(String value) {
    setState(() {
      switch (_step) {
        case 0:
          _selectedSize = value;
          break;
        case 1:
          _selectedColor = value;
          break;
        case 2:
          _selectedHabitat = value;
          break;
        case 3:
          _selectedBehavior = value;
          break;
      }
    });
  }

  String? _currentSelection() {
    switch (_step) {
      case 0:
        return _selectedSize;
      case 1:
        return _selectedColor;
      case 2:
        return _selectedHabitat;
      case 3:
        return _selectedBehavior;
    }
    return null;
  }

  void _next() {
    if (_step < _steps.length - 1) {
      _slideAnim.reset();
      _slideAnim.forward();
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() => _step++);
    } else {
      _showResults();
    }
  }

  void _prev() {
    if (_step > 0) {
      _slideAnim.reset();
      _slideAnim.forward();
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() => _step--);
    }
  }

  void _showResults() {
    context.read<SpeciesBloc>().add(FilterSpecies(
      size: _selectedSize ?? 'Toutes',
      habitat: _selectedHabitat ?? 'Tous',
    ));
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ResultsScreen(
          size: _selectedSize,
          color: _selectedColor,
          habitat: _selectedHabitat,
          behavior: _selectedBehavior,
        ),
      ),
    );
  }

  void _reset() {
    setState(() {
      _step = 0;
      _selectedSize = null;
      _selectedColor = null;
      _selectedHabitat = null;
      _selectedBehavior = null;
    });
    _pageCtrl.animateToPage(0,
        duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(),
          _buildProgressBar(),
          Expanded(
            child: PageView.builder(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                return _buildStepPage(_steps[index]);
              },
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF624C54), Color(0xFF8B6A74)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Identification guidée',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Étape ${_step + 1} / ${_steps.length}',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _reset,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.refresh, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      color: _primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: List.generate(_steps.length, (i) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 4),
              height: 4,
              decoration: BoxDecoration(
                color: i <= _step
                    ? _tertiary
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepPage(_WizardStep step) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(step.icon, color: _primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.question,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: step.options.map((opt) {
              final isSelected = _currentSelection() == opt.filterValue;
              return GestureDetector(
                onTap: () => _selectOption(opt.filterValue),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? _primary : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? _primary : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        opt.icon,
                        size: 28,
                        color: isSelected ? Colors.white : _primary,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        opt.label,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : _primary,
                        ),
                      ),
                      if (opt.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            opt.description,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: isSelected
                                  ? Colors.white70
                                  : Colors.grey[500],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final hasSelection = _currentSelection() != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: _prev,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: const BorderSide(color: _primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Retour',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ),
          if (_step > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: AnimatedOpacity(
              opacity: hasSelection ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 200),
              child: ElevatedButton(
                onPressed: hasSelection ? _next : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: hasSelection ? 4 : 0,
                  shadowColor: _primary.withOpacity(0.4),
                ),
                child: Text(
                  _step < _steps.length - 1 ? 'Suivant →' : '🔍 Voir les résultats',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Écran résultats du wizard ─────────────────────────────────────────────────
class _ResultsScreen extends StatelessWidget {
  final String? size;
  final String? color;
  final String? habitat;
  final String? behavior;

  static const _primary = Color(0xFF624C54);
  static const _secondary = Color(0xFF90CDC6);
  static const _bg = Color(0xFFEFEAE4);

  const _ResultsScreen({this.size, this.color, this.habitat, this.behavior});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        title: Text(
          'Résultats',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.tune, color: Colors.white70, size: 18),
            label: Text('Affiner',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFiltersChips(),
          Expanded(
            child: BlocBuilder<SpeciesBloc, SpeciesState>(
              builder: (context, state) {
                if (state is SpeciesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is SpeciesLoaded) {
                  final list = state.filteredSpecies;
                  if (list.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final species = list[index];
                      return _SpeciesResultCard(species: species);
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersChips() {
    final filters = <String>[];
    if (size != null) filters.add(size!);
    if (habitat != null) filters.add(habitat!);
    if (behavior != null) filters.add(behavior!);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 6,
              children: filters.map((f) {
                return Chip(
                  label: Text(f,
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: Colors.white)),
                  backgroundColor: _primary,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🦅', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(
            'Aucune espèce trouvée',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez d\'ajuster vos critères',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Recommencer'),
          ),
        ],
      ),
    );
  }
}

class _SpeciesResultCard extends StatelessWidget {
  final dynamic species;

  static const _primary = Color(0xFF624C54);
  static const _secondary = Color(0xFF90CDC6);

  const _SpeciesResultCard({required this.species});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => SpeciesDetailScreen(species: species)),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: species.imageUrls.isNotEmpty
                    ? species.imageUrls[0]
                    : '',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(width: 100, height: 100, color: Colors.grey[100]),
                errorWidget: (_, __, ___) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[100],
                  child: const Icon(Icons.image_not_supported,
                      color: Colors.grey),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      species.commonName,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _primary,
                      ),
                    ),
                    Text(
                      species.scientificName,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _chip(species.habitat, _secondary),
                        const SizedBox(width: 4),
                        _chip(species.size.split(' ')[0], _primary),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.chevron_right, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ── Modèles internes ──────────────────────────────────────────────────────────
class _WizardStep {
  final String question;
  final IconData icon;
  final List<_Option> options;
  const _WizardStep(
      {required this.question, required this.icon, required this.options});
}

class _Option {
  final String label;
  final String description;
  final IconData icon;
  final String filterValue;
  const _Option(this.label, this.description, this.icon, this.filterValue);
}
