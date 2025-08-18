import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();


  static void initTimezones() async{
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
  }
  static Future<void> initNotifications() async {
    // Initialize timezone for scheduled notifications
    initTimezones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  static Future<void> scheduleReminder({
    required int notiId,
    required String title,
    required String body,
    required DateTime startTime,
  }) async {
    initTimezones();
    await _notificationsPlugin.zonedSchedule(
      notiId,
      title,
      body,
      tz.TZDateTime.from(startTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminders',
          channelDescription: 'Reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,


    );
  }

  static Future<void> cancelReminder(int id) async {
    await _notificationsPlugin.cancel(id);
  }
  static void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse,
      ) {
    debugPrint('noti response : ${notificationResponse.payload}');
  }

  static Future<List<PendingNotificationRequest>> getNotis() async{
    return await _notificationsPlugin.pendingNotificationRequests();
  }

}
