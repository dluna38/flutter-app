import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:myapp/helpers/notification_helper.dart';
import '../data/plant.dart';
import '../data/database_helper.dart';
import '../data/reminder.dart';
import '../helpers/notification_helper.dart';
import '../helpers/string_helpers.dart';

class AddReminderScreen extends StatefulWidget {
  final Plant plant;

  const AddReminderScreen({super.key, required this.plant});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  late Plant plant;
  late ColorScheme colorScheme;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    plant = widget.plant;
  }

  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay(hour: 9, minute: 0);

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.dial,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      debugPrint('Guardar: $pickedTime');
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _saveReminder() async {
    int? days = int.tryParse(_daysController.text);
    if (days == null || days < 1) {
      return;
    }
    DateTime now = DateTime.now();
    DateTime nextDue = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    ).add(Duration(days: days));
    //DateTime nextDue = now.add(Duration(minutes: 16));

    Reminder reminder = Reminder(
      plantId: widget.plant.id!,
      task: 'Tu planta ${plant.name}: ${_taskController.text}',
      frequencyDays: days,
      nextDue: nextDue,
      active: 1,
    );
    debugPrint('remider $reminder');

    try {
      int idReminder = await DatabaseHelper().insertReminder(reminder);
      reminder.id = idReminder;
      Reminder.scheduleNotification(reminder);
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      DatabaseHelper().insertLog(
        "fallo al insertar el care event",
        level: LevelLog.error.normalName,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar recordatorio'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(labelText: 'Que recordar?'),
            ),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              controller: _daysController,
              decoration: const InputDecoration(
                labelText: 'A partir de hoy, cada tantos dias',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'A las: ${_selectedTime.format(context)}',
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.timer_sharp),
                  onPressed: () => _selectTime(context),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Spacer(),
            // Botón para guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _saveReminder();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Reminder',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
