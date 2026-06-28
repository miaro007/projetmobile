import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/models/bird.dart';
import '../bloc/bird_bloc.dart';
import '../bloc/bird_state.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  static const _primary = Color(0xFF624C54);
  static const _secondary = Color(0xFF90CDC6);
  static const _tertiary = Color(0xFFF6C69D);
  static const _bg = Color(0xFFEFEAE4);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: BlocBuilder<BirdBloc, BirdState>(
        builder: (context, state) {
          final birds = state is BirdsLoaded ? state.birds : <Bird>[];
          return FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              slivers: [
                _buildSliverHeader(birds.length),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCards(birds),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Observations par mois'),
                        const SizedBox(height: 12),
                        _buildMonthlyChart(birds),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Répartition par habitat'),
                        const SizedBox(height: 12),
                        _buildHabitatChart(birds),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Top espèces observées'),
                        const SizedBox(height: 12),
                        _buildTopSpecies(birds),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Activité par jour de la semaine'),
                        const SizedBox(height: 12),
                        _buildWeeklyActivity(birds),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverHeader(int total) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: _primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF624C54), Color(0xFF8B6A74)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mes Statistiques',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Vue d\'ensemble de vos observations',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today,
                            color: _tertiary, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Année ${DateTime.now().year}',
                          style: GoogleFonts.poppins(
                              color: _tertiary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        title: Text(
          'Statistiques',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        titlePadding:
            const EdgeInsetsDirectional.only(start: 16, bottom: 16),
      ),
    );
  }

  Widget _buildSummaryCards(List<Bird> birds) {
    final uniqueSpecies = birds.map((b) => b.name).toSet().length;
    final thisMonth = birds
        .where((b) =>
            b.observedAt.month == DateTime.now().month &&
            b.observedAt.year == DateTime.now().year)
        .length;
    final uniqueLocations = birds.map((b) => b.location).toSet().length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          icon: Icons.visibility,
          value: birds.length.toString(),
          label: 'Observations',
          color: _primary,
        ),
        _buildStatCard(
          icon: Icons.flutter_dash,
          value: uniqueSpecies.toString(),
          label: 'Espèces distinctes',
          color: _secondary,
        ),
        _buildStatCard(
          icon: Icons.calendar_month,
          value: thisMonth.toString(),
          label: 'Ce mois-ci',
          color: _tertiary,
          textColor: _primary,
        ),
        _buildStatCard(
          icon: Icons.location_on,
          value: uniqueLocations.toString(),
          label: 'Lieux visités',
          color: const Color(0xFF8B6A74),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    Color textColor = Colors.white,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: textColor.withOpacity(0.8), size: 22),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: textColor.withOpacity(0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: _primary,
      ),
    );
  }

  Widget _buildMonthlyChart(List<Bird> birds) {
    final now = DateTime.now();
    final months = List.generate(6, (i) {
      final d = DateTime(now.year, now.month - 5 + i);
      return d;
    });

    final counts = months.map((m) {
      return birds
          .where((b) => b.observedAt.month == m.month && b.observedAt.year == m.year)
          .length
          .toDouble();
    }).toList();

    final maxY = counts.reduce((a, b) => a > b ? a : b);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY == 0 ? 10 : maxY + 2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: _primary,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()} obs.',
                  GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final m = months[value.toInt()];
                  return Text(
                    DateFormat('MMM', 'fr_FR').format(m),
                    style: GoogleFonts.poppins(
                        fontSize: 10, color: Colors.grey[600]),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: Colors.grey.withOpacity(0.15), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(6, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: counts[i],
                  color: i == 5 ? _primary : _secondary.withOpacity(0.7),
                  width: 22,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHabitatChart(List<Bird> birds) {
    final habitatCount = <String, int>{};
    for (final b in birds) {
      habitatCount[b.habitat] = (habitatCount[b.habitat] ?? 0) + 1;
    }

    if (habitatCount.isEmpty) {
      habitatCount['Forêt'] = 3;
      habitatCount['Prairie'] = 2;
      habitatCount['Littoral'] = 1;
      habitatCount['Urbain'] = 2;
    }

    final colors = [_primary, _secondary, _tertiary, const Color(0xFF8B6A74), Colors.teal, Colors.orange];
    final entries = habitatCount.entries.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 150,
            width: 150,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: List.generate(entries.length, (i) {
                  final pct = (entries[i].value / birds.length * 100);
                  return PieChartSectionData(
                    color: colors[i % colors.length],
                    value: entries[i].value.toDouble(),
                    title: '${pct.toStringAsFixed(0)}%',
                    radius: 50,
                    titleStyle: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(entries.length, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors[i % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entries[i].key,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      Text(
                        '${entries[i].value}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSpecies(List<Bird> birds) {
    final speciesCount = <String, int>{};
    for (final b in birds) {
      speciesCount[b.name] = (speciesCount[b.name] ?? 0) + 1;
    }

    final sorted = speciesCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted.take(5).toList();

    if (top5.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'Aucune observation enregistrée',
            style: GoogleFonts.poppins(color: Colors.grey[500]),
          ),
        ),
      );
    }

    final maxVal = top5.first.value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(top5.length, (i) {
          final pct = top5[i].value / maxVal;
          final medals = ['🥇', '🥈', '🥉', '4️⃣', '5️⃣'];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(medals[i],
                      style: const TextStyle(fontSize: 18)),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            top5[i].key,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _primary,
                            ),
                          ),
                          Text(
                            '${top5[i].value} obs.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 6,
                          backgroundColor: _bg,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            i == 0 ? _primary : _secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWeeklyActivity(List<Bird> birds) {
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final counts = List.generate(7, (i) {
      return birds
          .where((b) => b.observedAt.weekday == i + 1)
          .length;
    });
    final maxVal = counts.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final h = maxVal == 0 ? 0.0 : (counts[i] / maxVal);
          final isWeekend = i >= 5;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Text(
                    counts[i].toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isWeekend ? _primary : _secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 600 + i * 80),
                    curve: Curves.easeOutCubic,
                    height: 80 * h + 4,
                    decoration: BoxDecoration(
                      color: isWeekend ? _primary : _secondary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    days[i],
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
