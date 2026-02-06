import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/app_router_provider.dart';
import '../../../core/services/demo_mode.dart';
import '../../../core/data/julio_profile_data.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    final isDemoMode = demoMode.isActive;
    final nombre = isDemoMode ? JulioProfileData.nombre : (user?.userMetadata?['display_name'] ?? 'Usuario');
    final email = isDemoMode ? 'julio@wemake.app' : (user?.email ?? '');

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar y nombre
          _ProfileHeader(
            nombre: nombre,
            email: email,
            nivel: 12,
            xp: 2450,
            xpToNext: 3000,
            onEditProfile: () => _showEditProfile(context),
          ),

          const SizedBox(height: 24),

          // Sección de cuenta
          _SectionHeader(title: 'Cuenta'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.person_outline,
                title: 'Editar perfil',
                subtitle: 'Nombre, foto, datos personales',
                onTap: () => _showEditProfile(context),
              ),
              _SettingsTile(
                icon: Icons.lock_outline,
                title: 'Seguridad',
                subtitle: 'Contraseña, autenticación',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notificaciones',
                subtitle: 'Recordatorios, alertas',
                onTap: () => context.push('/settings/notifications'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Integraciones
          _SectionHeader(title: 'Integraciones'),
          const SizedBox(height: 8),
          _IntegrationsCard(),

          const SizedBox(height: 24),

          // Preferencias
          _SectionHeader(title: 'Preferencias'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.palette_outlined,
                title: 'Apariencia',
                subtitle: 'Tema, colores',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Oscuro',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                onTap: () => _showThemeSettings(context),
              ),
              _SettingsTile(
                icon: Icons.language,
                title: 'Idioma',
                subtitle: 'Español',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.straighten,
                title: 'Unidades',
                subtitle: 'Métricas (kg, cm)',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Soporte
          _SectionHeader(title: 'Soporte'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.help_outline,
                title: 'Ayuda',
                subtitle: 'FAQ, tutoriales',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.feedback_outlined,
                title: 'Enviar feedback',
                subtitle: 'Sugerencias, reportar bugs',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'Acerca de',
                subtitle: 'Versión 1.0.0',
                onTap: () => _showAbout(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Cerrar sesión
          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context, ref),
            icon: Icon(Icons.logout, color: Colors.red.shade400),
            label: Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.red.shade400),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.red.shade200),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),

          const SizedBox(height: 32),

          // Version
          Center(
            child: Text(
              'WEMAKE v1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Editar perfil',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Avatar
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(
                            'J',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Campos
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      hintText: 'Julio Chipayo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'julio@wemake.app',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      hintText: 'Haciendo progreso cada día...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Perfil actualizado')),
                        );
                      },
                      child: const Text('Guardar cambios'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context, WidgetRef ref) {
    // Ya se muestra en la pantalla principal
  }

  void _showThemeSettings(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apariencia',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _ThemeOption(
              title: 'Claro',
              icon: Icons.light_mode,
              isSelected: false,
              onTap: () {},
            ),
            _ThemeOption(
              title: 'Oscuro',
              icon: Icons.dark_mode,
              isSelected: true,
              onTap: () {},
            ),
            _ThemeOption(
              title: 'Sistema',
              icon: Icons.brightness_auto,
              isSelected: false,
              onTap: () {},
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'WEMAKE',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'W',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      children: [
        const Text('Tu Super App para fitness, nutrición, hábitos y productividad.'),
      ],
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              if (demoMode.isActive) {
                demoMode.deactivate();
                context.go('/login');
              } else {
                ref.read(authServiceProvider).signOut();
              }
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

// ========== WIDGETS ==========

class _ProfileHeader extends StatelessWidget {
  final String nombre;
  final String email;
  final int nivel;
  final int xp;
  final int xpToNext;
  final VoidCallback onEditProfile;

  const _ProfileHeader({
    required this.nombre,
    required this.email,
    required this.nivel,
    required this.xp,
    required this.xpToNext,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final xpProgress = xpToNext > 0 ? xp / xpToNext : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              GestureDetector(
                onTap: onEditProfile,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Text(
                        nombre.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -5,
                      right: -5,
                      child: const Text('👑', style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      email,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Edit button
              IconButton(
                onPressed: onEditProfile,
                icon: const Icon(Icons.edit, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // XP Progress
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.emoji_events, color: Colors.amber, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Nivel $nivel',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$xp / $xpToNext XP',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: xpProgress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
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

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            trailing ?? Icon(
              Icons.chevron_right,
              color: theme.colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _IntegrationsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final integrations = [
      {
        'name': 'Toggl Track',
        'icon': Icons.timer,
        'color': Colors.pink,
        'connected': true,
      },
      {
        'name': 'ClickUp',
        'icon': Icons.task_alt,
        'color': Colors.purple,
        'connected': true,
      },
      {
        'name': 'Apple Health',
        'icon': Icons.favorite,
        'color': Colors.red,
        'connected': false,
      },
      {
        'name': 'Google Calendar',
        'icon': Icons.calendar_today,
        'color': Colors.blue,
        'connected': false,
      },
      {
        'name': 'Duolingo',
        'icon': Icons.school,
        'color': Colors.green,
        'connected': false,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Apps conectadas',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Ver todas'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: integrations.map((app) {
              final connected = app['connected'] as bool;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: connected
                      ? (app['color'] as Color).withOpacity(0.1)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: connected
                        ? (app['color'] as Color).withOpacity(0.3)
                        : theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      app['icon'] as IconData,
                      size: 16,
                      color: connected
                          ? app['color'] as Color
                          : theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      app['name'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: connected
                            ? app['color'] as Color
                            : theme.colorScheme.outline,
                        fontWeight: connected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    if (connected) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Colors.green,
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: isSelected ? theme.colorScheme.primary : null),
      title: Text(title),
      trailing: isSelected ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
      onTap: onTap,
    );
  }
}
