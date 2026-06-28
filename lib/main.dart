import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:projet_flutter/data/repositories/supabase_bird_repository.dart';
import 'package:projet_flutter/data/repositories/species_repository_impl.dart';
import 'package:projet_flutter/data/services/ebird_service.dart';
import 'package:projet_flutter/data/services/wikipedia_service.dart';
import 'package:projet_flutter/data/services/nuthatch_service.dart';
import 'package:projet_flutter/data/services/xeno_canto_service.dart';
import 'package:projet_flutter/presentation/bloc/bird_bloc.dart';
import 'package:projet_flutter/presentation/bloc/bird_event.dart';
import 'package:projet_flutter/presentation/bloc/species/species_bloc.dart';
import 'package:projet_flutter/presentation/bloc/species/species_event.dart';
import 'package:projet_flutter/presentation/bloc/auth/auth_bloc.dart';
import 'package:projet_flutter/presentation/screens/main_navigation_screen.dart';
import 'package:projet_flutter/presentation/screens/auth/login_screen.dart';
import 'package:projet_flutter/presentation/screens/splash_screen.dart';
import 'package:projet_flutter/presentation/screens/onboarding_screen.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // INITIALISATION SUPABASE
  try {
    await supabase.Supabase.initialize(
      url: 'https://lpmvauxwhabuvbumuldv.supabase.co',
      anonKey: 'sb_publishable_znGIxHW7Q4Jz1jGKMAPB0Q_I0DWt-Vo',
    );
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
  }


  // Services
  final eBirdService = EBirdService(apiKey: 'dclbd7b85jqh');
  final wikipediaService = WikipediaService();
  final nuthatchService = NuthatchService();
  final xenoCantoService = XenoCantoService(apiKey: '3067f311b2ea555a29ebfc5ddc579a48f079be4a');

  // Repositories
  final birdRepository = SupabaseBirdRepository();
  final speciesRepository = SpeciesRepositoryImpl(
    eBirdService: eBirdService,
    wikipediaService: wikipediaService,
    nuthatchService: nuthatchService,
    xenoCantoService: xenoCantoService,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc()..add(AuthCheckRequested()),
        ),
        BlocProvider<BirdBloc>(
          create: (context) => BirdBloc(birdRepository: birdRepository)..add(LoadBirds()),
        ),
        BlocProvider<SpeciesBloc>(
          create: (context) => SpeciesBloc(speciesRepository: speciesRepository)..add(LoadAllSpecies()),
        ),
      ],
      child: const BirdWatchApp(),
    ),
  );
}

class BirdWatchApp extends StatelessWidget {
  const BirdWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BirdWatch Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF624C54),
          primary: const Color(0xFF624C54),
          secondary: const Color(0xFF90CDC6),
          tertiary: const Color(0xFFF6C69D),
          surface: const Color(0xFFFFFEFE),
        ),
        scaffoldBackgroundColor: const Color(0xFFEFEAE4),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFFEFEAE4),
          foregroundColor: Color(0xFF624C54),
          titleTextStyle: TextStyle(
            color: Color(0xFF624C54),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: const Color(0xFFFFFEFE),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return const MainNavigationScreen();
            }
            if (state is Unauthenticated) {
              return const LoginScreen();
            }
            if (state is AuthInitial || state is AuthLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return const LoginScreen();
          },
        ),
      },
    );
  }
}
