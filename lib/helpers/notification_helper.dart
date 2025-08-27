import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:myapp/data/plant.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../data/database_helper.dart';
import '../screens/detail_plant_screen.dart';
import 'package:myapp/main.dart';


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
    try {
      initTimezones();

      const AndroidInitializationSettings initializationSettingsAndroid =
              AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
              InitializationSettings(android: initializationSettingsAndroid);

      await _notificationsPlugin.initialize(
            initializationSettings,
            onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
          );
    } catch (e) {
      DatabaseHelper().insertLog("error initNotications: $e",level: 'ERROR');
    }

  }

  static Future<void> scheduleReminder({
    required int notiId,
    required String title,
    required String body,
    required DateTime startTime,
    String? payload
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
          icon: 'ic_stat_plant'
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload
    );
  }

  static Future<void> cancelReminder(int id) async {
    await _notificationsPlugin.cancel(id);
  }
  static void onDidReceiveNotificationResponse (
      NotificationResponse notificationResponse,
      ) async{
    if(notificationResponse.payload !=null){
      DatabaseHelper().insertLog("open notification");
      try {
        Map<String, dynamic> data = json.decode(notificationResponse.payload!);

        if(data.containsKey('type') && data['type'].toString() == 'care-event'){
                Plant? plant = await DatabaseHelper().getPlantById(int.tryParse(data['plantId'])!);
                if(plant ==null){
                  return;
                }
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                    builder: (context) => PlantDetailScreen(plant: plant,notiResponse: notificationResponse,),
                  ),
                );
              }
      } catch (e) {
        DatabaseHelper().insertLog("error open notification: $e",level: 'ERROR');
      }
    }

    DatabaseHelper().insertLog('noti response : ${notificationResponse.payload}');
  }

  static Future<List<PendingNotificationRequest>> getNotis() async{
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  static String createPayload(Map<String, dynamic> notificationPayload){
    return json.encode(notificationPayload);
  }

}

