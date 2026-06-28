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
import 'package:projet_flutter/presentation/bloc/theme_cubit.dart';
import 'package:projet_flutter/core/theme/app_theme.dart';
import 'package:projet_flutter/presentation/screens/main_navigation_screen.dart';
import 'package:projet_flutter/presentation/screens/auth/login_screen.dart';
import 'package:projet_flutter/presentation/screens/splash_screen.dart';
import 'package:projet_flutter/presentation/screens/onboarding_screen.dart';

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
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(),
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
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          title: 'Akany',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
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
      },
    );
  }
}
