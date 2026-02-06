import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Notification types for the app
enum NotificationType {
  habitReminder,
  mealReminder,
  workoutReminder,
  waterReminder,
  streakWarning,
  dailyMotivation,
  insightAlert,
  achievementUnlocked,
}

/// Notification configuration
class NotificationConfig {
  final int id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime? scheduledTime;
  final String? payload;

  const NotificationConfig({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.scheduledTime,
    this.payload,
  });
}

/// Notification Service for local push notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Check if notifications are supported on this platform
  bool get isSupported {
    if (kIsWeb) return false;
    // Notifications work on iOS, Android, and macOS
    return defaultTargetPlatform == TargetPlatform.iOS ||
           defaultTargetPlatform == TargetPlatform.android ||
           defaultTargetPlatform == TargetPlatform.macOS;
  }

  /// Check if full notification features are available (scheduling, etc)
  bool get hasFullSupport {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
           defaultTargetPlatform == TargetPlatform.android;
  }

  /// Initialize the notification service
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    if (!isSupported) return false;

    try {
      // Initialize timezone
      tz_data.initializeTimeZones();

      // Android settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS/macOS settings
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Linux settings (basic)
      const linuxSettings = LinuxInitializationSettings(
        defaultActionName: 'Open notification',
      );

      final initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
      );

      final result = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = result ?? false;
      return _isInitialized;
    } catch (e) {
      debugPrint('Notification initialization failed: $e');
      return false;
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (!isSupported) return false;

    try {
      // iOS
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iOS = _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        if (iOS != null) {
          final result = await iOS.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          return result ?? false;
        }
      }

      // macOS
      if (defaultTargetPlatform == TargetPlatform.macOS) {
        final macOS = _notifications.resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>();
        if (macOS != null) {
          final result = await macOS.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          return result ?? false;
        }
      }

      // Android
      if (defaultTargetPlatform == TargetPlatform.android) {
        final android = _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        if (android != null) {
          final result = await android.requestNotificationsPermission();
          return result ?? false;
        }
      }

      return true;
    } catch (e) {
      debugPrint('Permission request failed: $e');
      return false;
    }
  }

  /// Show immediate notification
  Future<void> showNotification(NotificationConfig config) async {
    if (!isSupported) return;

    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }

    try {
      final details = _getNotificationDetails(config.type);

      await _notifications.show(
        config.id,
        config.title,
        config.body,
        details,
        payload: config.payload,
      );
    } catch (e) {
      debugPrint('Show notification failed: $e');
    }
  }

  /// Schedule a notification for a specific time
  Future<void> scheduleNotification(NotificationConfig config) async {
    if (!hasFullSupport) {
      // On macOS/Linux, just show immediately as a fallback
      if (isSupported) {
        await showNotification(config);
      }
      return;
    }

    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }

    if (config.scheduledTime == null) return;

    try {
      final details = _getNotificationDetails(config.type);
      final scheduledDate = tz.TZDateTime.from(config.scheduledTime!, tz.local);

      await _notifications.zonedSchedule(
        config.id,
        config.title,
        config.body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: config.payload,
      );
    } catch (e) {
      debugPrint('Schedule notification failed: $e');
    }
  }

  /// Schedule daily notification at specific time
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required NotificationType type,
    String? payload,
  }) async {
    if (!hasFullSupport) return;
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }

    try {
      final details = _getNotificationDetails(type);
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Schedule daily notification failed: $e');
    }
  }

  /// Schedule water reminders throughout the day
  Future<void> scheduleWaterReminders({
    int startHour = 8,
    int endHour = 21,
    int intervalHours = 2,
  }) async {
    if (!hasFullSupport) return;

    // Cancel existing water reminders
    await cancelNotificationsByType(NotificationType.waterReminder);

    int idCounter = 1000; // Water reminder IDs start at 1000

    for (int hour = startHour; hour <= endHour; hour += intervalHours) {
      await scheduleDailyNotification(
        id: idCounter++,
        title: 'Hora de hidratarte!',
        body: 'Toma un vaso de agua para mantenerte energizado.',
        hour: hour,
        minute: 0,
        type: NotificationType.waterReminder,
        payload: 'water_reminder',
      );
    }
  }

  /// Schedule meal reminders
  Future<void> scheduleMealReminders() async {
    if (!hasFullSupport) return;

    // Cancel existing meal reminders
    await cancelNotificationsByType(NotificationType.mealReminder);

    // Breakfast reminder
    await scheduleDailyNotification(
      id: 2001,
      title: 'Hora del desayuno!',
      body: 'Empieza el dia con un buen desayuno.',
      hour: 8,
      minute: 0,
      type: NotificationType.mealReminder,
      payload: 'meal_breakfast',
    );

    // Lunch reminder
    await scheduleDailyNotification(
      id: 2002,
      title: 'Hora del almuerzo!',
      body: 'No olvides registrar tu almuerzo.',
      hour: 13,
      minute: 0,
      type: NotificationType.mealReminder,
      payload: 'meal_lunch',
    );

    // Dinner reminder
    await scheduleDailyNotification(
      id: 2003,
      title: 'Hora de la cena!',
      body: 'Registra tu cena para completar tu tracking nutricional.',
      hour: 20,
      minute: 0,
      type: NotificationType.mealReminder,
      payload: 'meal_dinner',
    );
  }

  /// Schedule workout reminder
  Future<void> scheduleWorkoutReminder({
    required int hour,
    required int minute,
    String? workoutName,
  }) async {
    if (!hasFullSupport) return;

    await scheduleDailyNotification(
      id: 3001,
      title: 'Es hora de entrenar!',
      body: workoutName != null
          ? 'Tu rutina de $workoutName te espera.'
          : 'No olvides tu entrenamiento de hoy.',
      hour: hour,
      minute: minute,
      type: NotificationType.workoutReminder,
      payload: 'workout_reminder',
    );
  }

  /// Schedule habit reminder
  Future<void> scheduleHabitReminder({
    required int id,
    required String habitName,
    required int hour,
    required int minute,
  }) async {
    if (!hasFullSupport) return;

    await scheduleDailyNotification(
      id: 4000 + id.hashCode % 1000,
      title: 'Recordatorio: $habitName',
      body: 'Es momento de completar tu habito.',
      hour: hour,
      minute: minute,
      type: NotificationType.habitReminder,
      payload: 'habit_$id',
    );
  }

  /// Schedule streak warning (evening reminder if streak at risk)
  Future<void> scheduleStreakWarning() async {
    if (!hasFullSupport) return;

    await scheduleDailyNotification(
      id: 5001,
      title: 'Tu racha esta en riesgo!',
      body: 'Aun no has alcanzado tu meta diaria. Completa tus habitos antes de medianoche.',
      hour: 21,
      minute: 0,
      type: NotificationType.streakWarning,
      payload: 'streak_warning',
    );
  }

  /// Schedule daily motivation quote
  Future<void> scheduleDailyMotivation({int hour = 7, int minute = 30}) async {
    if (!hasFullSupport) return;

    final quotes = [
      'Cada dia es una nueva oportunidad para ser mejor.',
      'El exito es la suma de pequenos esfuerzos repetidos.',
      'La consistencia supera al talento.',
      'Hoy es el dia para hacer que suceda.',
      'Tu unico limite eres tu mismo.',
    ];

    final quote = quotes[DateTime.now().day % quotes.length];

    await scheduleDailyNotification(
      id: 6001,
      title: 'Buenos dias, Maker!',
      body: quote,
      hour: hour,
      minute: minute,
      type: NotificationType.dailyMotivation,
      payload: 'daily_motivation',
    );
  }

  /// Show achievement unlocked notification
  Future<void> showAchievementNotification({
    required String achievementName,
    required String description,
  }) async {
    await showNotification(NotificationConfig(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Logro desbloqueado!',
      body: '$achievementName - $description',
      type: NotificationType.achievementUnlocked,
      payload: 'achievement',
    ));
  }

  /// Show insight alert notification
  Future<void> showInsightNotification({
    required String title,
    required String insight,
  }) async {
    await showNotification(NotificationConfig(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: insight,
      type: NotificationType.insightAlert,
      payload: 'insight',
    ));
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    if (!isSupported) return;
    try {
      await _notifications.cancel(id);
    } catch (e) {
      debugPrint('Cancel notification failed: $e');
    }
  }

  /// Cancel all notifications of a specific type
  Future<void> cancelNotificationsByType(NotificationType type) async {
    if (!isSupported) return;
    try {
      // Cancel known ID ranges for each type
      switch (type) {
        case NotificationType.waterReminder:
          for (int i = 1000; i < 1100; i++) {
            await _notifications.cancel(i);
          }
          break;
        case NotificationType.mealReminder:
          for (int i = 2001; i <= 2003; i++) {
            await _notifications.cancel(i);
          }
          break;
        case NotificationType.workoutReminder:
          await _notifications.cancel(3001);
          break;
        case NotificationType.habitReminder:
          for (int i = 4000; i < 5000; i++) {
            await _notifications.cancel(i);
          }
          break;
        case NotificationType.streakWarning:
          await _notifications.cancel(5001);
          break;
        case NotificationType.dailyMotivation:
          await _notifications.cancel(6001);
          break;
        default:
          break;
      }
    } catch (e) {
      debugPrint('Cancel notifications by type failed: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!isSupported) return;
    try {
      await _notifications.cancelAll();
    } catch (e) {
      debugPrint('Cancel all notifications failed: $e');
    }
  }

  /// Get pending notifications count
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!isSupported) return [];
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Get pending notifications failed: $e');
      return [];
    }
  }

  /// Get notification details based on type
  NotificationDetails _getNotificationDetails(NotificationType type) {
    String channelId;
    String channelName;
    String channelDescription;
    Importance importance;

    switch (type) {
      case NotificationType.habitReminder:
        channelId = 'habit_reminders';
        channelName = 'Recordatorios de Habitos';
        channelDescription = 'Recordatorios para completar tus habitos';
        importance = Importance.high;
        break;
      case NotificationType.mealReminder:
        channelId = 'meal_reminders';
        channelName = 'Recordatorios de Comidas';
        channelDescription = 'Recordatorios para registrar tus comidas';
        importance = Importance.defaultImportance;
        break;
      case NotificationType.workoutReminder:
        channelId = 'workout_reminders';
        channelName = 'Recordatorios de Entrenamiento';
        channelDescription = 'Recordatorios para tus sesiones de entrenamiento';
        importance = Importance.high;
        break;
      case NotificationType.waterReminder:
        channelId = 'water_reminders';
        channelName = 'Recordatorios de Agua';
        channelDescription = 'Recordatorios para mantenerte hidratado';
        importance = Importance.low;
        break;
      case NotificationType.streakWarning:
        channelId = 'streak_warnings';
        channelName = 'Alertas de Racha';
        channelDescription = 'Alertas cuando tu racha esta en riesgo';
        importance = Importance.high;
        break;
      case NotificationType.dailyMotivation:
        channelId = 'daily_motivation';
        channelName = 'Motivacion Diaria';
        channelDescription = 'Tu dosis diaria de motivacion';
        importance = Importance.low;
        break;
      case NotificationType.insightAlert:
        channelId = 'insights';
        channelName = 'Insights';
        channelDescription = 'Nuevos insights basados en tus datos';
        importance = Importance.defaultImportance;
        break;
      case NotificationType.achievementUnlocked:
        channelId = 'achievements';
        channelName = 'Logros';
        channelDescription = 'Notificaciones de logros desbloqueados';
        importance = Importance.high;
        break;
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: importance,
      priority: importance == Importance.high ? Priority.high : Priority.defaultPriority,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    // Handle navigation based on payload
    debugPrint('Notification tapped with payload: $payload');
  }
}

/// Global notification service instance
final notificationService = NotificationService();
