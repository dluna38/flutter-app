import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:myapp/data/database_helper.dart';

import '../helpers/notification_helper.dart';

class Reminder {
  int? id;
  final int plantId;
  final String task;
  final int frequencyDays;
  DateTime nextDue;
  int active;

  Reminder({
    this.id,
    required this.plantId,
    required this.task,
    required this.frequencyDays,
    required this.nextDue,
    required this.active
  });

  static void scheduleNotification(Reminder reminder) {
    if(reminder.id == null){
      debugPrint('Reminder id is null');
      DatabaseHelper().insertLog('reminder id null',level: 'ERROR');
      return;
    }

    NotificationHelper.scheduleReminder(
      notiId: reminder.id!,
      title: "PlantApp",
      body: reminder.task,
      startTime: reminder.nextDue,
    );
    //DateTime.now().millisecondsSinceEpoch()
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plantId': plantId,
      'task': task,
      'active': active,
      'nextDue': nextDue.millisecondsSinceEpoch,
      'frequencyDays': frequencyDays,
    };
  }

  // Método para crear un Reminder desde un mapa de la base de datos
  static Reminder fromMap(Map<String, dynamic> map) {

    return Reminder(
      id: map['id'],
      plantId: map['plantId'],
      task: map['task'],
      active:  map['active'] ?? 0,
      nextDue: DateTime.fromMillisecondsSinceEpoch(map['nextDue']),
      frequencyDays: map['frequency'],
    );
  }

  @override
  String toString() {
    return 'Reminder{id: $id, plantId: $plantId, task: $task, frequencyDays: $frequencyDays, nextDue: $nextDue, active: $active}';
  }


}
