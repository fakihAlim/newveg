import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Initialize Timezone Database
    tz.initializeTimeZones();
    _configureLocalTimezone();

    // Android Settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS / macOS Settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint("Notification clicked: ${details.payload}");
      },
    );

    _initialized = true;
  }

  void _configureLocalTimezone() {
    try {
      // Guess / configure local timezone location
      final String timeZoneName = DateTime.now().timeZoneName;
      if (timeZoneName.contains('+') || timeZoneName.contains('-')) {
        // If it's an offset format, fallback to default Indonesian timezone
        tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      } else {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      }
    } catch (_) {
      // Safe fallback to Jakarta timezone
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }
    }
  }

  /// Request permissions for local notifications (iOS and Android 13+)
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final iosImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    } else if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidImplementation?.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  /// Schedule a daily recurring notification at a specific time
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await init();

    // Cancel existing one first to avoid duplicates
    await cancelNotification(id);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'meal_reminders_channel',
      'Pengingat Pola Makan',
      channelDescription: 'Alarm pengingat jadwal makan sehat harian (Sarapan, Makan Siang, Makan Malam)',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
