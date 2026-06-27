import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mon Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(),
            const SizedBox(height: 30),
            _buildAchievementSection(),
            const SizedBox(height: 30),
            _buildMenuSection(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=1000&auto=format&fit=crop'),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                child: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Marc Ornitho', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const Text('Observateur Passionné • Bordeaux, FR', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: const Text('NIVEAU 12', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildAchievementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('BADGES RÉCENTS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12, letterSpacing: 1.2)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildBadgeItem('Lève-tard', Icons.wb_twilight, Colors.blue),
              _buildBadgeItem('Explorateur', Icons.explore, Colors.green),
              _buildBadgeItem('Photographe', Icons.camera_alt, Colors.purple),
              _buildBadgeItem('Scientifique', Icons.biotech, Colors.red),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeItem(String label, IconData icon, Color color) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        children: [
          _buildMenuItem(Icons.favorite_border, 'Mes espèces favorites', '12 espèces'),
          _buildMenuItem(Icons.map_outlined, 'Mes lieux favoris', '5 lieux'),
          _buildMenuItem(Icons.file_download_outlined, 'Données hors-ligne', 'Pack Europe (1.2 Go)'),
          _buildMenuItem(Icons.share_outlined, 'Partager mon profil', ''),
          _buildMenuItem(Icons.help_outline, 'Aide & Support', ''),
          _buildMenuItem(
            Icons.logout,
            'Déconnexion',
            '',
            isLast: true,
            textColor: Colors.red,
            onTap: () {
              context.read<AuthBloc>().add(SignOutRequested());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, {bool isLast = false, Color? textColor, VoidCallback? onTap}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: textColor ?? Colors.green[800]),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
          subtitle: subtitle.isNotEmpty ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
          trailing: const Icon(Icons.chevron_right, size: 20),
          onTap: onTap,
        ),
        if (!isLast) Divider(height: 1, indent: 60, color: Colors.grey[100]),
      ],
    );
  }
}
