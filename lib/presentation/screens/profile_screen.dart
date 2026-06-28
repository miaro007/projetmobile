import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/theme_cubit.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/bird_bloc.dart';
import '../bloc/bird_state.dart';
import '../../domain/models/bird.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _primary = Color(0xFF624C54);
  static const _secondary = Color(0xFF90CDC6);
  static const _tertiary = Color(0xFFF6C69D);
  static const _bg = Color(0xFFEFEAE4); // kept for internal widgets

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BirdBloc, BirdState>(
      builder: (context, birdState) {
        final birds = birdState is BirdsLoaded ? birdState.birds : <Bird>[];
        final level = _computeLevel(birds.length);
        final xp = birds.length;
        final xpToNext = _xpForLevel(level + 1);
        final xpCurrent = _xpForLevel(level);
        final progress = xpCurrent == xpToNext
            ? 1.0
            : (xp - xpCurrent) / (xpToNext - xpCurrent);

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: CustomScrollView(
            slivers: [
              _buildSliverHeader(context, level, xp, xpToNext, progress, birds.length),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildStatsRow(birds),
                      const SizedBox(height: 24),
                      _buildBadgesSection(birds),
                      const SizedBox(height: 24),
                      _buildAchievementsSection(birds),
                      const SizedBox(height: 24),
                      _buildMenuSection(context),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _computeLevel(int observations) {
    if (observations >= 200) return 20;
    if (observations >= 100) return 15;
    if (observations >= 50) return 10;
    if (observations >= 20) return 7;
    if (observations >= 10) return 5;
    if (observations >= 5) return 3;
    if (observations >= 1) return 2;
    return 1;
  }

  int _xpForLevel(int level) => level * level * 3;

  Widget _buildSliverHeader(BuildContext context, int level, int xp,
      int xpToNext, double progress, int totalBirds) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () => _showSettings(context),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF624C54), Color(0xFF8B6A74)],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Avatar
                Stack(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _tertiary, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 50, color: Color(0xFF624C54)),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: _secondary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.edit,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Ornithologue Akany',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Observateur Passionné',
                  style: GoogleFonts.poppins(
                      color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),
                // Niveau + XP
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: _tertiary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'NIVEAU $level',
                              style: GoogleFonts.poppins(
                                color: _primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Text(
                            '$xp / $xpToNext XP',
                            style: GoogleFonts.poppins(
                                color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: Colors.white24,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(_tertiary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        title: Text(
          'Mon Profil',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        titlePadding:
            const EdgeInsetsDirectional.only(start: 16, bottom: 16),
      ),
    );
  }

  Widget _buildStatsRow(List<Bird> birds) {
    final unique = birds.map((b) => b.name).toSet().length;
    final locations = birds.map((b) => b.location).toSet().length;
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
          _statCell(birds.length.toString(), 'Observations'),
          _divider(),
          _statCell(unique.toString(), 'Espèces'),
          _divider(),
          _statCell(locations.toString(), 'Lieux'),
        ],
      ),
    );
  }

  Widget _statCell(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _primary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
                color: Colors.grey[600], fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 36,
        color: Colors.grey[200],
      );

  Widget _buildBadgesSection(List<Bird> birds) {
    final allBadges = _computeBadges(birds);
    final unlocked = allBadges.where((b) => b.unlocked).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Badges débloqués',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: _primary,
              ),
            ),
            Text(
              '${unlocked.length} / ${allBadges.length}',
              style: GoogleFonts.poppins(
                  color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: allBadges.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _BadgeTile(badge: allBadges[i]),
          ),
        ),
      ],
    );
  }

  List<_Badge> _computeBadges(List<Bird> birds) {
    final count = birds.length;
    final unique = birds.map((b) => b.name).toSet().length;
    final locations = birds.map((b) => b.location).toSet().length;

    return [
      _Badge(
        icon: Icons.visibility,
        label: 'Débutant',
        description: '1ère observation',
        unlocked: count >= 1,
        color: _secondary,
      ),
      _Badge(
        icon: Icons.pets,
        label: 'Passionné',
        description: '10 observations',
        unlocked: count >= 10,
        color: _tertiary,
      ),
      _Badge(
        icon: Icons.nature,
        label: 'Explorateur',
        description: '3 lieux visités',
        unlocked: locations >= 3,
        color: _secondary,
      ),
      _Badge(
        icon: Icons.menu_book,
        label: 'Naturaliste',
        description: '5 espèces distinctes',
        unlocked: unique >= 5,
        color: _primary,
      ),
      _Badge(
        icon: Icons.emoji_events,
        label: 'Expert',
        description: '50 observations',
        unlocked: count >= 50,
        color: _tertiary,
      ),
      _Badge(
        icon: Icons.flight,
        label: 'Maître',
        description: '100 observations',
        unlocked: count >= 100,
        color: _primary,
      ),
    ];
  }

  Widget _buildAchievementsSection(List<Bird> birds) {
    final badges = _computeBadges(birds);
    final locked = badges.where((b) => !b.unlocked).toList();
    if (locked.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prochains objectifs',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: _primary,
          ),
        ),
        const SizedBox(height: 12),
        ...locked.take(3).map((b) => _AchievementRow(badge: b)),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            Icons.favorite_border,
            'Mes espèces favorites',
            '',
            color: _secondary,
          ),
          _buildMenuItem(
            Icons.map_outlined,
            'Mes lieux favoris',
            '',
            color: _secondary,
          ),
          _buildMenuItem(
            Icons.file_download_outlined,
            'Données hors-ligne',
            '',
            color: _secondary,
          ),
          _buildMenuItem(
            Icons.share_outlined,
            'Partager mon profil',
            '',
            color: _secondary,
          ),
          _buildMenuItem(
            Icons.help_outline,
            'Aide & Support',
            '',
            color: _secondary,
          ),
          _buildMenuItem(
            Icons.logout,
            'Déconnexion',
            '',
            isLast: true,
            textColor: _primary,
            color: _primary,
            onTap: () {
              context.read<AuthBloc>().add(SignOutRequested());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle, {
    bool isLast = false,
    Color? textColor,
    Color color = _secondary,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: textColor ?? color, size: 20),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: textColor,
              fontSize: 14,
            ),
          ),
          subtitle: subtitle.isNotEmpty
              ? Text(subtitle,
                  style: GoogleFonts.poppins(fontSize: 12))
              : null,
          trailing:
              Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
          onTap: onTap,
        ),
        if (!isLast) Divider(height: 1, indent: 70, color: Colors.grey[100]),
      ],
    );
  }
  void _showSettings(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    final authBloc = context.read<AuthBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paramètres',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(modalContext).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.brightness_6, color: Theme.of(modalContext).colorScheme.primary),
                title: Text('Thème Sombre / Clair', style: GoogleFonts.poppins()),
                trailing: BlocBuilder<ThemeCubit, ThemeMode>(
                  bloc: themeCubit,
                  builder: (ctx, themeMode) {
                    return Switch(
                      value: themeMode == ThemeMode.dark,
                      activeThumbColor: Theme.of(modalContext).colorScheme.secondary,
                      onChanged: (val) => themeCubit.toggleTheme(),
                    );
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: Text('Se déconnecter', style: GoogleFonts.poppins(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(modalContext);
                  authBloc.add(SignOutRequested());
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

// ── Widgets internes ─────────────────────────────────────────────────────────
class _Badge {
  final IconData icon;
  final String label;
  final String description;
  final bool unlocked;
  final Color color;

  const _Badge({
    required this.icon,
    required this.label,
    required this.description,
    required this.unlocked,
    required this.color,
  });
}

class _BadgeTile extends StatelessWidget {
  final _Badge badge;

  static const _primary = Color(0xFF624C54);

  const _BadgeTile({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: badge.unlocked ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              badge.unlocked ? badge.color.withOpacity(0.3) : Colors.grey[200]!,
        ),
        boxShadow: badge.unlocked
            ? [
                BoxShadow(
                  color: badge.color.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                badge.icon,
                size: 28,
                color: badge.unlocked ? badge.color : Colors.grey.withOpacity(0.4),
              ),
              if (!badge.unlocked)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock,
                        size: 12, color: Colors.grey),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            badge.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: badge.unlocked ? _primary : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementRow extends StatelessWidget {
  final _Badge badge;

  static const _primary = Color(0xFF624C54);
  static const _bg = Color(0xFFEFEAE4);

  const _AchievementRow({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(badge.icon, size: 22, color: Colors.grey[400]),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _primary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  badge.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.lock_outline, size: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
