import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      imageUrl: 'assets/images/onboarding1.jpg',
      localAsset: true,
      icon: Icons.filter_alt_outlined,
      title: 'Identifiez',
      subtitle: 'les oiseaux par filtres',
      description: 'Appliquez des filtres simples pour identifier rapidement l\'oiseau que vous observez dans la nature.',
    ),
    _OnboardingData(
      imageUrl: 'assets/images/onboarding2.jpg',
      localAsset: true,
      icon: Icons.menu_book_outlined,
      title: 'Consultez',
      subtitle: 'le guide des espèces',
      description: 'Parcourez toutes les espèces d\'oiseaux en les recherchant par nom ou par famille.',
    ),
    _OnboardingData(
      imageUrl: 'assets/images/onboarding3.webp',
      localAsset: true,
      icon: Icons.bookmark_border_outlined,
      title: 'Créez',
      subtitle: 'vos listes d\'observations',
      description: 'Créez et éditez des listes personnalisées pour enregistrer et partager vos observations.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToAuth();
    }
  }

  void _skip() => _navigateToAuth();

  void _navigateToAuth() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              _fadeController.reset();
              _fadeController.forward();
            },
            itemBuilder: (context, index) {
              return _OnboardingPage(
                data: _pages[index],
                fadeAnimation: _fadeAnimation,
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 48),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _skip,
                    child: Text(
                      'Passer',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? const Color(0xFFF6C69D)
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _goToNext,
                    child: Text(
                      _currentPage < _pages.length - 1 ? 'Suivant' : 'Commencer',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFFF6C69D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  final Animation<double> fadeAnimation;

  const _OnboardingPage({required this.data, required this.fadeAnimation});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        data.localAsset 
            ? Image.asset(
                data.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF624C54),
                  child: const Icon(Icons.image_not_supported, size: 80, color: Color(0xFFF6C69D)),
                ),
              )
            : Image.network(
                data.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF624C54),
                  child: const Icon(Icons.image_not_supported, size: 80, color: Color(0xFFF6C69D)),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: const Color(0xFF624C54),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF6C69D)),
                      ),
                    ),
                  );
                },
              ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.30, 0.60, 1.0],
                colors: [
                  Colors.transparent,
                  const Color(0xFF624C54).withOpacity(0.80),
                  const Color(0xFF624C54),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: 28,
          right: 28,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFF6C69D).withOpacity(0.7),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(data.icon, color: const Color(0xFFF6C69D), size: 30),
                ),
                const SizedBox(height: 20),
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                Text(
                  data.subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 19,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFF6C69D),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.72),
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardingData {
  final String imageUrl;
  final bool localAsset;
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;

  const _OnboardingData({
    required this.imageUrl,
    required this.localAsset,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}
