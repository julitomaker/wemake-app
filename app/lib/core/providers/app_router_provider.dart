import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/nutrition/screens/nutrition_screen.dart';
import '../../features/nutrition/screens/add_meal_screen.dart';
import '../../features/training/screens/training_screen.dart';
import '../../features/habits/screens/habits_screen.dart';
import '../../features/habits/screens/add_habit_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/gamification/screens/store_screen.dart';
import '../../features/insights/screens/insights_screen.dart';
import '../../features/settings/screens/notification_settings_screen.dart';
import '../../features/sleep/screens/sleep_screen.dart';
import '../providers/auth_provider.dart';
import '../services/demo_mode.dart';

/// Route names for type-safe navigation
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String nutrition = '/nutrition';
  static const String nutritionAdd = '/nutrition/add';
  static const String nutritionScan = '/nutrition/scan';
  static const String training = '/training';
  static const String trainingStart = '/training/start';
  static const String trainingSession = '/training/session';
  static const String habits = '/habits';
  static const String habitsAdd = '/habits/add';
  static const String profile = '/profile';
  static const String store = '/store';
  static const String insights = '/insights';
  static const String notificationSettings = '/settings/notifications';
  static const String settings = '/settings';
  static const String sleep = '/sleep';
}

/// Provider for GoRouter instance
final appRouterProvider = Provider<GoRouter>((ref) {
  // In demo mode, skip auth entirely
  final isDemoMode = demoMode.isActive;

  AsyncValue<User?>? authState;
  if (!isDemoMode) {
    authState = ref.watch(authStateProvider);
  }

  return GoRouter(
    initialLocation: isDemoMode ? AppRoutes.home : AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Demo mode: allow all navigation, no auth checks
      if (isDemoMode) {
        // Only redirect splash to home in demo mode
        if (state.matchedLocation == AppRoutes.splash) {
          return AppRoutes.home;
        }
        return null;
      }

      final isLoggedIn = authState?.value != null;
      final isOnboarded =
          authState?.value?.userMetadata?['onboarding_completed'] == true;
      final isLoggingIn = state.matchedLocation == AppRoutes.login;
      final isOnboarding = state.matchedLocation == AppRoutes.onboarding;
      final isSplash = state.matchedLocation == AppRoutes.splash;

      // If still loading, stay on splash
      if ((authState?.isLoading ?? false) && isSplash) {
        return null;
      }

      // Not logged in -> go to login
      if (!isLoggedIn && !isLoggingIn && !isSplash) {
        return AppRoutes.login;
      }

      // Logged in but not onboarded -> go to onboarding
      if (isLoggedIn && !isOnboarded && !isOnboarding) {
        return AppRoutes.onboarding;
      }

      // Logged in and onboarded, but on login/onboarding -> go to home
      if (isLoggedIn &&
          isOnboarded &&
          (isLoggingIn || isOnboarding || isSplash)) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Onboarding
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main App (with bottom navigation shell)
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          // Home / Daily Flow
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),

          // Nutrition
          GoRoute(
            path: AppRoutes.nutrition,
            name: 'nutrition',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NutritionScreen(),
            ),
          ),

          // Training
          GoRoute(
            path: AppRoutes.training,
            name: 'training',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TrainingScreen(),
            ),
          ),

          // Habits
          GoRoute(
            path: AppRoutes.habits,
            name: 'habits',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HabitsScreen(),
            ),
          ),

          // Profile
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // Standalone routes (outside shell - for modals, full screens)

      // Add Meal Screen
      GoRoute(
        path: AppRoutes.nutritionAdd,
        name: 'nutritionAdd',
        builder: (context, state) {
          final mealType = state.uri.queryParameters['type'];
          return AddMealScreen(mealType: mealType);
        },
      ),

      // Scan Meal Screen (placeholder for now)
      GoRoute(
        path: AppRoutes.nutritionScan,
        name: 'nutritionScan',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Escanear Comida',
          icon: Icons.qr_code_scanner,
        ),
      ),

      // Training Start (select routine)
      GoRoute(
        path: AppRoutes.trainingStart,
        name: 'trainingStart',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Seleccionar Rutina',
          icon: Icons.list_alt,
        ),
      ),

      // Workout Session Screen - Now handled in TrainingScreen
      GoRoute(
        path: AppRoutes.trainingSession,
        name: 'trainingSession',
        builder: (context, state) {
          // Las sesiones ahora se manejan dentro de TrainingScreen
          return const TrainingScreen();
        },
      ),

      // Add Habit Screen
      GoRoute(
        path: AppRoutes.habitsAdd,
        name: 'habitsAdd',
        builder: (context, state) => const AddHabitScreen(),
      ),

      // Store Screen
      GoRoute(
        path: AppRoutes.store,
        name: 'store',
        builder: (context, state) => const StoreScreen(),
      ),

      // Insights Screen
      GoRoute(
        path: AppRoutes.insights,
        name: 'insights',
        builder: (context, state) => const InsightsScreen(),
      ),

      // Notification Settings Screen
      GoRoute(
        path: AppRoutes.notificationSettings,
        name: 'notificationSettings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),

      // General Settings Screen
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Sleep Screen
      GoRoute(
        path: AppRoutes.sleep,
        name: 'sleep',
        builder: (context, state) => const SleepScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Ir al inicio'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Main shell widget with bottom navigation
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const MainBottomNav(),
    );
  }
}

/// Bottom navigation bar
class MainBottomNav extends StatelessWidget {
  const MainBottomNav({super.key});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.home)) return 0;
    if (location.startsWith(AppRoutes.nutrition)) return 1;
    if (location.startsWith(AppRoutes.training)) return 2;
    if (location.startsWith(AppRoutes.habits)) return 3;
    if (location.startsWith(AppRoutes.profile)) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.nutrition);
        break;
      case 2:
        context.go(AppRoutes.training);
        break;
      case 3:
        context.go(AppRoutes.habits);
        break;
      case 4:
        context.go(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Hoy',
                isSelected: _calculateSelectedIndex(context) == 0,
                onTap: () => _onTap(context, 0),
              ),
              _NavItem(
                icon: Icons.restaurant_outlined,
                activeIcon: Icons.restaurant,
                label: 'Comida',
                isSelected: _calculateSelectedIndex(context) == 1,
                onTap: () => _onTap(context, 1),
              ),
              _NavItem(
                icon: Icons.fitness_center_outlined,
                activeIcon: Icons.fitness_center,
                label: 'Entreno',
                isSelected: _calculateSelectedIndex(context) == 2,
                onTap: () => _onTap(context, 2),
              ),
              _NavItem(
                icon: Icons.repeat_outlined,
                activeIcon: Icons.repeat,
                label: 'Habitos',
                isSelected: _calculateSelectedIndex(context) == 3,
                onTap: () => _onTap(context, 3),
              ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Perfil',
                isSelected: _calculateSelectedIndex(context) == 4,
                onTap: () => _onTap(context, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withOpacity(0.5);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder screen for unimplemented routes
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderScreen({
    required this.title,
    this.icon = Icons.construction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Proximamente',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Esta seccion esta en desarrollo',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Settings Screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuracion'),
      ),
      body: ListView(
        children: [
          _SettingsSection(
            title: 'General',
            children: [
              _SettingsTile(
                icon: Icons.notifications_outlined,
                iconColor: Colors.orange,
                title: 'Notificaciones',
                subtitle: 'Configura tus recordatorios',
                onTap: () => context.push(AppRoutes.notificationSettings),
              ),
              _SettingsTile(
                icon: Icons.palette_outlined,
                iconColor: Colors.purple,
                title: 'Apariencia',
                subtitle: 'Tema y personalizacion',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.language_outlined,
                iconColor: Colors.blue,
                title: 'Idioma',
                subtitle: 'Espanol',
                onTap: () {},
              ),
            ],
          ),
          _SettingsSection(
            title: 'Cuenta',
            children: [
              _SettingsTile(
                icon: Icons.person_outline,
                iconColor: Colors.green,
                title: 'Perfil',
                subtitle: 'Edita tu informacion personal',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.lock_outline,
                iconColor: Colors.red,
                title: 'Privacidad',
                subtitle: 'Control de datos y permisos',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.download_outlined,
                iconColor: Colors.teal,
                title: 'Exportar datos',
                subtitle: 'Descarga tus datos en CSV',
                onTap: () {},
              ),
            ],
          ),
          _SettingsSection(
            title: 'Soporte',
            children: [
              _SettingsTile(
                icon: Icons.help_outline,
                iconColor: Colors.amber,
                title: 'Ayuda y FAQ',
                subtitle: 'Preguntas frecuentes',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.feedback_outlined,
                iconColor: Colors.indigo,
                title: 'Enviar feedback',
                subtitle: 'Ayudanos a mejorar',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.info_outline,
                iconColor: Colors.grey,
                title: 'Acerca de',
                subtitle: 'Version 1.0.0',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () {
                // Show logout confirmation
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Cerrar sesion'),
                    content: const Text('Estas seguro que quieres cerrar sesion?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Implement logout
                          context.go(AppRoutes.login);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Cerrar sesion'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Cerrar sesion', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
