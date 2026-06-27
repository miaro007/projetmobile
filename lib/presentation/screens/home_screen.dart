import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'add_bird_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEAE4),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurvedHeader(context),
            const SizedBox(height: 24),
            _buildMisListasSection(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCurvedHeader(BuildContext context) {
    return SizedBox(
      height: 440,
      child: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            height: 400,
            child: ClipPath(
              clipper: _ArcClipper(),
              child: Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c8/Passer_domesticus_male_%2815%29.jpg/800px-Passer_domesticus_male_%2815%29.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          
          Positioned(
            top: 50,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.menu, color: Colors.white, size: 28),
                const SizedBox(height: 12),
                Text(
                  'Gorrión',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    shadows: [const Shadow(color: Colors.black45, blurRadius: 10)],
                  ),
                ),
                Text(
                  '¿Querés saber más? >',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    shadows: [const Shadow(color: Colors.black45, blurRadius: 8)],
                  ),
                ),
              ],
            ),
          ),
          
          Positioned(
            top: 50,
            right: 20,
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Colors.white, size: 20),
                const SizedBox(width: 4),
                Text('GPS', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          Positioned(
            top: 180,
            right: -10,
            child: Container(
              width: 220,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFEAE4),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: Color(0xFF624C54),
                        child: Icon(Icons.location_on, size: 14, color: Color(0xFFEFEAE4)),
                      ),
                      const SizedBox(width: 8),
                      Text('Activar Gps', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF624C54))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Para mejorar la experiencia, activa la ubicación del dispositivo.',
                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('No, gracias', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600])),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('Aceptar', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF624C54))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Iniciar Identificación',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    shadows: [const Shadow(color: Colors.black54, blurRadius: 10)],
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBirdScreen()));
                  },
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFF624C54),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF624C54).withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 8))
                      ],
                    ),
                    child: const Center(
                      child: Icon(FontAwesomeIcons.binoculars, color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMisListasSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mis listas',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF624C54),
                ),
              ),
              Text(
                'Ver todas',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            children: [
              _buildListCard('Vacaciones', '9 observaciones', 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Anthus_campestris_MHNT.jpg/800px-Anthus_campestris_MHNT.jpg'),
              _buildListCard('Vacaciones', '4 observaciones', 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Falco_rupicoloides.jpg/800px-Falco_rupicoloides.jpg'),
              _buildListCard('Ciudad', '14 observaciones', 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/Columba_livia_-_01.jpg/800px-Columba_livia_-_01.jpg'),
              _buildListCard('Mar del Plata', '3 observaciones', 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5a/Larus_dominicanus_1.jpg/800px-Larus_dominicanus_1.jpg'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListCard(String title, String subtitle, String imageUrl) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              height: 100,
              width: 130,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF624C54),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2, 
      size.height + 40, 
      size.width, 
      size.height - 60 
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
