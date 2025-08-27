
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
    DatabaseHelper().insertLog('new notification: id:${reminder.id}|due:${reminder.nextDue}',level: 'INFO');
    NotificationHelper.scheduleReminder(
      notiId: reminder.id!,
      title: "Recordatorio - Mis plantitas",
      body: reminder.task,
      startTime: reminder.nextDue,
      payload: NotificationHelper.createPayload({'type':'care-event','plantId':reminder.plantId.toString(),'body':reminder.task})
    );
    //DateTime.now().millisecondsSinceEpoch()
  }

  DateTime setNewNextDue(){
    nextDue = nextDue.add(Duration(days: frequencyDays));
    return nextDue;
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

  void delete(){
    if(id ==null){
      return;
    }
    NotificationHelper.cancelReminder(id!);
    DatabaseHelper().deleteReminder(id!);
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
