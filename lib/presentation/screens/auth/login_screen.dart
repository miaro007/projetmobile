import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../bloc/auth/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLogin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    if (_isLogin) {
      context.read<AuthBloc>().add(SignInRequested(email, password));
    } else {
      context.read<AuthBloc>().add(SignUpRequested(email, password));
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryDark = Color(0xFF624C54);
    const lightBeige = Color(0xFFF3EFEA);

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
          if (state is Unauthenticated && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      // Logo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/app_logo.jpg',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Akany',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: primaryDark,
                        ),
                      ),
                      const SizedBox(height: 60),
                      
                      // Email Field
                      Container(
                        decoration: BoxDecoration(
                          color: lightBeige,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _emailController,
                          style: GoogleFonts.poppins(color: primaryDark),
                          decoration: InputDecoration(
                            hintText: 'Adresse e-mail',
                            hintStyle: GoogleFonts.poppins(color: primaryDark.withOpacity(0.6)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Password Field
                      Container(
                        decoration: BoxDecoration(
                          color: lightBeige,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: GoogleFonts.poppins(color: primaryDark),
                          decoration: InputDecoration(
                            hintText: 'Mot de passe',
                            hintStyle: GoogleFonts.poppins(color: primaryDark.withOpacity(0.6)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: primaryDark.withOpacity(0.6),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Forgot password and Login button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _isLogin
                              ? TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Veuillez contacter le support pour réinitialiser votre mot de passe.'),
                                        backgroundColor: primaryDark,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Mot de passe oublié ?',
                                    style: GoogleFonts.poppins(
                                      color: primaryDark.withOpacity(0.8),
                                      fontSize: 13,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              if (state is AuthLoading) {
                                return const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(primaryDark));
                              }
                              return ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryDark,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  _isLogin ? 'Se connecter' : 'S\'inscrire',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      
                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: primaryDark.withOpacity(0.2))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Ou se connecter avec :',
                              style: GoogleFonts.poppins(
                                color: primaryDark.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: primaryDark.withOpacity(0.2))),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Social Icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialIcon(
                            icon: FontAwesomeIcons.google,
                            color: Colors.red,
                            onTap: () {
                              context.read<AuthBloc>().add(const SocialSignInRequested(OAuthProvider.google));
                            },
                          ),
                        ],
                      ),
                      
                      // Mode demo bouton (Optionnel pour tests rapides)
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(
                            const SignInRequested('demo@birdwatch.pro', 'demo123'),
                          );
                        },
                        child: Text(
                          'Mode Démo',
                          style: GoogleFonts.poppins(
                            color: primaryDark.withOpacity(0.5),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              
              // Bottom Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: const BoxDecoration(
                  color: lightBeige,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin ? 'Première fois ? ' : 'Déjà un compte ? ',
                      style: GoogleFonts.poppins(
                        color: primaryDark.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(
                        _isLogin ? 'Inscrivez-vous !' : 'Se connecter',
                        style: GoogleFonts.poppins(
                          color: primaryDark,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon({required IconData icon, required Color color, required VoidCallback onTap}) {
    const primaryDark = Color(0xFF624C54);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: primaryDark.withOpacity(0.2)),
        ),
        child: Center(
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
      ),
    );
  }
}
