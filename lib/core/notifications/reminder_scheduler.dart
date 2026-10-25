import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../router/app_router.dart';
import '../theme/sorbet_colors.dart';

/// A notification ready to schedule: localized texts and the route it opens.
final class ScheduledNotification {
  const ScheduledNotification({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final DateTime at;
  final String title;
  final String body;

  /// Route pushed when the notification is tapped.
  final String payload;
}

/// Replaces every pending reminder with a new set.
abstract interface class ReminderScheduler {
  Future<void> replaceAll(
    List<ScheduledNotification> notifications, {
    required String channelName,
    required String channelDescription,
  });
}

final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => LocalReminderScheduler(
    onOpen: (route) => ref.read(routerProvider).push(route),
  ),
);

/// flutter_local_notifications, with inexact alarms (no special Android
/// permission; the system may shift them by a few minutes).
class LocalReminderScheduler implements ReminderScheduler {
  LocalReminderScheduler({required this.onOpen});

  final void Function(String route) onOpen;
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _ready;
  bool _askedPermission = false;

  Future<void> _init() async {
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(
        tz.getLocation((await FlutterTimezone.getLocalTimezone()).identifier),
      );
    } catch (e) {
      // ponytail: an unknown zone leaves UTC, so times shift by the offset; fine until a report says otherwise.
      debugPrint('Little Steps: local time zone unavailable ($e)');
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        // White sparkle, android/app/src/main/res/drawable/ic_notification.xml.
        android: AndroidInitializationSettings('@drawable/ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (r) {
        if (r.payload case final route?) onOpen(route);
      },
    );
    final launch = await _plugin.getNotificationAppLaunchDetails();
    final route = launch?.notificationResponse?.payload;
    if ((launch?.didNotificationLaunchApp ?? false) && route != null) {
      onOpen(route);
    }
  }

  Future<void> _askPermission() async {
    if (_askedPermission) return;
    _askedPermission = true;
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, sound: true);
  }

  @override
  Future<void> replaceAll(
    List<ScheduledNotification> notifications, {
    required String channelName,
    required String channelDescription,
  }) async {
    await (_ready ??= _init());
    if (notifications.isNotEmpty) await _askPermission();
    await _plugin.cancelAll();
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'reminders',
        channelName,
        channelDescription: channelDescription,
        // Tints the white sparkle in the notification shade.
        color: SorbetColors.light.accent,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    for (final n in notifications) {
      await _plugin.zonedSchedule(
        id: n.id,
        scheduledDate: tz.TZDateTime.from(n.at, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: n.title,
        body: n.body,
        payload: n.payload,
      );
    }
  }
}
