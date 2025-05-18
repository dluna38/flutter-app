import 'dart:ffi';

class Reminder {
  Long? id;
  final Long plantId;
  final String task;
  final String frequency;
  final DateTime nextDue;

  Reminder({
    this.id,
    required this.plantId,
    required this.task,
    required this.frequency,
    required this.nextDue,
  });
}