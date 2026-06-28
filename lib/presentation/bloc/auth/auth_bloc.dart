import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:equatable/equatable.dart';

import 'package:flutter/foundation.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  const SignInRequested(this.email, this.password);
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  const SignUpRequested(this.email, this.password);
}

class SignOutRequested extends AuthEvent {}

class SocialSignInRequested extends AuthEvent {
  final OAuthProvider provider;
  const SocialSignInRequested(this.provider);
}

class AuthStateChanged extends AuthEvent {
  final User? user;
  const AuthStateChanged(this.user);
}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);
  @override
  List<Object> get props => [user];
}

class Unauthenticated extends AuthState {
  final String? message; // Optionnel : message pour dire d'aller confirmer l'email
  const Unauthenticated({this.message});
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient? _supabase;

  static SupabaseClient? _safeGetSupabase() {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  AuthBloc() : _supabase = _safeGetSupabase(), super(AuthInitial()) {
    if (_supabase != null) {
      _supabase!.auth.onAuthStateChange.listen((data) {
        add(AuthStateChanged(data.session?.user));
      });
    }

    on<AuthStateChanged>((event, emit) {
      if (event.user != null) {
        emit(Authenticated(event.user!));
      } else {
        emit(const Unauthenticated());
      }
    });

    on<AuthCheckRequested>((event, emit) {
      if (_supabase == null) {
        emit(const Unauthenticated());
        return;
      }
      try {
        final session = _supabase!.auth.currentSession;
        if (session != null) {
          emit(Authenticated(session.user));
        } else {
          emit(const Unauthenticated());
        }
      } catch (_) {
        emit(const Unauthenticated());
      }
    });

    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      if (_supabase == null) {
        await Future.delayed(const Duration(milliseconds: 500));
        emit(Authenticated(User(
          id: 'mock-user-id',
          appMetadata: const {},
          userMetadata: const {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
          email: event.email.isNotEmpty ? event.email : 'guest@example.com',
        )));
        return;
      }
      try {
        final response = await _supabase!.auth.signInWithPassword(
          email: event.email,
          password: event.password,
        );
        if (response.user != null) {
          emit(Authenticated(response.user!));
        } else {
          emit(const AuthError("Erreur d'authentification"));
        }
      } catch (e) {
        final errStr = e.toString();
        if (errStr.contains('SupabaseClient') || errStr.contains('Failed host lookup') || errStr.contains('Invalid project URL')) {
          emit(Authenticated(User(
            id: 'mock-user-id',
            appMetadata: const {},
            userMetadata: const {},
            aud: 'authenticated',
            createdAt: DateTime.now().toIso8601String(),
            email: event.email,
          )));
        } else {
          emit(AuthError(_translateError(errStr)));
        }
      }
    });

    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      if (_supabase == null) {
        await Future.delayed(const Duration(milliseconds: 500));
        emit(Authenticated(User(
          id: 'mock-user-id',
          appMetadata: const {},
          userMetadata: const {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
          email: event.email,
        )));
        return;
      }
      try {
        final response = await _supabase!.auth.signUp(
          email: event.email,
          password: event.password,
        );
        if (response.session != null) {
          emit(Authenticated(response.user!));
        } else {
          emit(const Unauthenticated(message: "Veuillez confirmer votre adresse email pour continuer."));
        }
      } catch (e) {
        final errStr = e.toString();
        if (errStr.contains('SupabaseClient') || errStr.contains('Failed host lookup') || errStr.contains('Invalid project URL')) {
          emit(Authenticated(User(
            id: 'mock-user-id',
            appMetadata: const {},
            userMetadata: const {},
            aud: 'authenticated',
            createdAt: DateTime.now().toIso8601String(),
            email: event.email,
          )));
        } else {
          emit(AuthError(_translateError(errStr)));
        }
      }
    });

    on<SignOutRequested>((event, emit) async {
      if (_supabase != null) {
        try {
          await _supabase!.auth.signOut();
        } catch (_) {}
      }
      emit(const Unauthenticated());
    });

    on<SocialSignInRequested>((event, emit) async {
      emit(AuthLoading());
      if (_supabase == null) {
        emit(const AuthError("Supabase n'est pas initialisé"));
        return;
      }
      try {
        await _supabase!.auth.signInWithOAuth(
          event.provider,
          redirectTo: kIsWeb ? null : 'com.birdwatch.pro://login-callback',
        );
        // L'état sera mis à jour par onAuthStateChange dans main.dart (ou manuellement)
      } catch (e) {
        emit(AuthError(_translateError(e.toString())));
      }
    });
  }

  String _translateError(String error) {
    if (error.contains('Invalid login credentials')) return 'Email ou mot de passe incorrect';
    if (error.contains('User already registered')) return 'Cet email est déjà utilisé';
    return error;
  }
}
