import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/notification_service.dart';

/// Notification settings state
class NotificationSettings {
  final bool waterReminders;
  final bool mealReminders;
  final bool workoutReminders;
  final bool habitReminders;
  final bool streakWarnings;
  final bool dailyMotivation;
  final bool insightAlerts;
  final bool achievementAlerts;
  final int waterIntervalHours;
  final int workoutReminderHour;
  final int motivationHour;

  const NotificationSettings({
    this.waterReminders = true,
    this.mealReminders = true,
    this.workoutReminders = true,
    this.habitReminders = true,
    this.streakWarnings = true,
    this.dailyMotivation = true,
    this.insightAlerts = true,
    this.achievementAlerts = true,
    this.waterIntervalHours = 2,
    this.workoutReminderHour = 17,
    this.motivationHour = 7,
  });

  NotificationSettings copyWith({
    bool? waterReminders,
    bool? mealReminders,
    bool? workoutReminders,
    bool? habitReminders,
    bool? streakWarnings,
    bool? dailyMotivation,
    bool? insightAlerts,
    bool? achievementAlerts,
    int? waterIntervalHours,
    int? workoutReminderHour,
    int? motivationHour,
  }) {
    return NotificationSettings(
      waterReminders: waterReminders ?? this.waterReminders,
      mealReminders: mealReminders ?? this.mealReminders,
      workoutReminders: workoutReminders ?? this.workoutReminders,
      habitReminders: habitReminders ?? this.habitReminders,
      streakWarnings: streakWarnings ?? this.streakWarnings,
      dailyMotivation: dailyMotivation ?? this.dailyMotivation,
      insightAlerts: insightAlerts ?? this.insightAlerts,
      achievementAlerts: achievementAlerts ?? this.achievementAlerts,
      waterIntervalHours: waterIntervalHours ?? this.waterIntervalHours,
      workoutReminderHour: workoutReminderHour ?? this.workoutReminderHour,
      motivationHour: motivationHour ?? this.motivationHour,
    );
  }
}

/// Notification settings provider
final notificationSettingsProvider =
    StateProvider<NotificationSettings>((ref) => const NotificationSettings());

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final granted = await notificationService.requestPermissions();
    setState(() => _permissionGranted = granted);
  }

  Future<void> _applySettings(NotificationSettings settings) async {
    // Cancel all and reschedule based on settings
    await notificationService.cancelAllNotifications();

    if (settings.waterReminders) {
      await notificationService.scheduleWaterReminders(
        intervalHours: settings.waterIntervalHours,
      );
    }

    if (settings.mealReminders) {
      await notificationService.scheduleMealReminders();
    }

    if (settings.workoutReminders) {
      await notificationService.scheduleWorkoutReminder(
        hour: settings.workoutReminderHour,
        minute: 0,
      );
    }

    if (settings.streakWarnings) {
      await notificationService.scheduleStreakWarning();
    }

    if (settings.dailyMotivation) {
      await notificationService.scheduleDailyMotivation(
        hour: settings.motivationHour,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notificaciones actualizadas'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
      ),
      body: ListView(
        children: [
          // Permission status
          if (!_permissionGranted)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Permisos no otorgados',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.orange[800],
                          ),
                        ),
                        Text(
                          'Habilita las notificaciones en configuracion del sistema.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _checkPermissions,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),

          // Section: Recordatorios
          _buildSectionHeader(theme, 'Recordatorios'),

          _buildSwitchTile(
            title: 'Recordatorios de agua',
            subtitle: 'Recibe recordatorios para mantenerte hidratado',
            icon: Icons.water_drop,
            iconColor: Colors.blue,
            value: settings.waterReminders,
            onChanged: (value) {
              ref.read(notificationSettingsProvider.notifier).state =
                  settings.copyWith(waterReminders: value);
            },
          ),

          if (settings.waterReminders)
            _buildSliderTile(
              title: 'Intervalo de recordatorios',
              subtitle: 'Cada ${settings.waterIntervalHours} horas',
              value: settings.waterIntervalHours.toDouble(),
              min: 1,
              max: 4,
              divisions: 3,
              onChanged: (value) {
                ref.read(notificationSettingsProvider.notifier).state =
                    settings.copyWith(waterIntervalHours: value.round());
              },
            ),

          _buildSwitchTile(
            title: 'Recordatorios de comidas',
            subtitle: 'Desayuno, almuerzo y cena',
            icon: Icons.restaurant,
            iconColor: Colors.orange,
            value: settings.mealReminders,
            onChanged: (value) {
              ref.read(notificationSettingsProvider.notifier).state =
                  settings.copyWith(mealReminders: value);
            },
          ),

          _buildSwitchTile(
            title: 'Recordatorios de entrenamiento',
            subtitle: 'No olvides tu sesion de ejercicio',
            icon: Icons.fitness_center,
            iconColor: Colors.red,
            value: settings.workoutReminders,
            onChanged: (value) {
              ref.read(notificationSettingsProvider.notifier).state =
                  settings.copyWith(workoutReminders: value);
            },
          ),

          if (settings.workoutReminders)
            _buildTimePicker(
              title: 'Hora del recordatorio',
              hour: settings.workoutReminderHour,
              onChanged: (hour) {
                ref.read(notificationSettingsProvider.notifier).state =
                    settings.copyWith(workoutReminderHour: hour);
              },
            ),

          _buildSwitchTile(
            title: 'Recordatorios de habitos',
            subtitle: 'Recibe recordatorios para cada habito',
            icon: Icons.check_circle,
            iconColor: Colors.green,
            value: settings.habitReminders,
            onChanged: (value) {
              ref.read(notificationSettingsProvider.notifier).state =
                  settings.copyWith(habitReminders: value);
            },
          ),

          const Divider(),

          // Section: Alertas
          _buildSectionHeader(theme, 'Alertas'),

          _buildSwitchTile(
            title: 'Alertas de racha',
            subtitle: 'Aviso cuando tu racha esta en riesgo',
            icon: Icons.local_fire_department,
            iconColor: Colors.deepOrange,
            value: settings.streakWarnings,
            onChanged: (value) {
              ref.read(notificationSettingsProvider.notifier).state =
                  settings.copyWith(streakWarnings: value);
            },
          ),

          _buildSwitchTile(
            title: 'Alertas de insights',
            subtitle: 'Nuevos descubrimientos de tus datos',
            icon: Icons.lightbulb,
            iconColor: Colors.amber,
            value: settings.insightAlerts,
            onChanged: (value) {
              ref.read(notificationSettingsProvider.notifier).state =
                  settings.copyWith(insightAlerts: value);
            },
          ),

          _buildSwitchTile(
            title: 'Logros desbloqueados',
            subtitle: 'Celebra tus logros',
            icon: Icons.emoji_events,
            iconColor: Colors.purple,
            value: settings.achievementAlerts,
            onChanged: (value) {
              ref.read(notificationSettingsProvider.notifier).state =
                  settings.copyWith(achievementAlerts: value);
            },
          ),

          const Divider(),

          // Section: Motivacion
          _buildSectionHeader(theme, 'Motivacion'),

          _buildSwitchTile(
            title: 'Motivacion diaria',
            subtitle: 'Empieza el dia con una frase motivacional',
            icon: Icons.wb_sunny,
            iconColor: Colors.yellow[700]!,
            value: settings.dailyMotivation,
            onChanged: (value) {
              ref.read(notificationSettingsProvider.notifier).state =
                  settings.copyWith(dailyMotivation: value);
            },
          ),

          if (settings.dailyMotivation)
            _buildTimePicker(
              title: 'Hora de la motivacion',
              hour: settings.motivationHour,
              onChanged: (hour) {
                ref.read(notificationSettingsProvider.notifier).state =
                    settings.copyWith(motivationHour: hour);
              },
            ),

          const SizedBox(height: 24),

          // Apply button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () => _applySettings(settings),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Aplicar cambios'),
            ),
          ),

          const SizedBox(height: 16),

          // Test notification button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () async {
                await notificationService.showNotification(
                  NotificationConfig(
                    id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                    title: 'Notificacion de prueba',
                    body: 'Las notificaciones estan funcionando correctamente!',
                    type: NotificationType.dailyMotivation,
                  ),
                );
              },
              icon: const Icon(Icons.notifications_active),
              label: const Text('Enviar notificacion de prueba'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      secondary: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker({
    required String title,
    required int hour,
    required ValueChanged<int> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      trailing: TextButton(
        onPressed: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(hour: hour, minute: 0),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  alwaysUse24HourFormat: true,
                ),
                child: child!,
              );
            },
          );
          if (time != null) {
            onChanged(time.hour);
          }
        },
        child: Text(
          '${hour.toString().padLeft(2, '0')}:00',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
