import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/pressable_scale.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String? _errorMessage;
  late final AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.signInWithGoogle();

      // OAuth redirects to browser, auth state will be captured by stream
      // For web/desktop, we check if user is now logged in
      if (authService.currentUser != null && mounted) {
        final completed = await authService.hasCompletedOnboarding();
        if (mounted) {
          if (completed) {
            context.go('/home');
          } else {
            context.go('/onboarding');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al iniciar sesion. Intenta de nuevo.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.signInWithApple();

      // OAuth redirects to browser, auth state will be captured by stream
      if (authService.currentUser != null && mounted) {
        final completed = await authService.hasCompletedOnboarding();
        if (mounted) {
          if (completed) {
            context.go('/home');
          } else {
            context.go('/onboarding');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al iniciar sesion. Intenta de nuevo.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, _) {
                final t = _backgroundController.value;
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: const [
                        Color(0xFF0D0D0F),
                        Color(0xFF131A2A),
                        Color(0xFF0D0D0F),
                      ],
                      begin: Alignment(-1 + t, -1),
                      end: Alignment(1 - t, 1),
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  _buildBranding(theme),

                  const Spacer(flex: 1),

                  _buildValueProposition(theme),

                  const Spacer(flex: 2),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  _buildSignInButtons(theme),

                  const SizedBox(height: 24),

                  _buildTerms(theme),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranding(ThemeData theme) {
    return Column(
      children: [
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'W',
              style: theme.textTheme.displayMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'WEMAKE',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'For Makers.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildValueProposition(ThemeData theme) {
    return Column(
      children: [
        Text(
          'La vida no se desea.\nSe construye.',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tu sistema operativo personal para\nfitness, nutricion, productividad y habitos.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButtons(ThemeData theme) {
    return Column(
      children: [
        // Google Sign In
        PressableScale(
          onTap: _isLoading ? null : _signInWithGoogle,
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _signInWithGoogle,
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : Image.network(
                      'https://www.google.com/favicon.ico',
                      width: 20,
                      height: 20,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.g_mobiledata,
                        color: theme.colorScheme.primary,
                      ),
                    ),
              label: const Text('Continuar con Google'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Apple Sign In
        PressableScale(
          onTap: _isLoading ? null : _signInWithApple,
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _signInWithApple,
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.apple, size: 24),
              label: const Text('Continuar con Apple'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.onSurface,
                foregroundColor: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTerms(ThemeData theme) {
    return Text.rich(
      TextSpan(
        text: 'Al continuar, aceptas nuestros ',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        children: [
          TextSpan(
            text: 'Terminos de Servicio',
            style: TextStyle(
              color: theme.colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
          const TextSpan(text: ' y '),
          TextSpan(
            text: 'Politica de Privacidad',
            style: TextStyle(
              color: theme.colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
