import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projet_flutter/main.dart';
import 'package:projet_flutter/presentation/bloc/auth/auth_bloc.dart';
import 'package:projet_flutter/presentation/screens/auth/login_screen.dart';


class TestGotrueAsyncStorage extends GotrueAsyncStorage {
  const TestGotrueAsyncStorage();

  @override
  Future<String?> getItem({required String key}) async => null;

  @override
  Future<void> removeItem({required String key}) async {}

  @override
  Future<void> setItem({required String key, required String value}) async {}
}

void main() {
  setUpAll(() async {
    // Initialise Supabase avec un stockage factice pour éviter d'utiliser SharedPreferences en mode test
    await Supabase.initialize(
      url: 'https://dummy.supabase.co',
      anonKey: 'dummy_key',
      authOptions: const FlutterAuthClientOptions(
        localStorage: EmptyLocalStorage(),
        pkceAsyncStorage: TestGotrueAsyncStorage(),
      ),
    );
  });

  testWidgets('Vérification du titre de l\'application', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>(
          create: (context) => AuthBloc()..add(AuthCheckRequested()),
          child: const LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('BirdWatch Pro'), findsOneWidget);
  });
}




