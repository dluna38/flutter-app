import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:myapp/helpers/notification_helper.dart';
import '../data/plant.dart';
import '../data/database_helper.dart';
import '../data/reminder.dart';
import '../helpers/notification_helper.dart';

class AddReminderScreen extends StatefulWidget {
  final Plant plant;

  const AddReminderScreen({super.key, required this.plant});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  late Plant plant;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    plant = widget.plant;
  }

  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
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
    DateTime nextDue = DateTime(now.year,now.month,now.day,_selectedTime.hour,_selectedTime.minute).add(Duration(days: days));


    Reminder reminder = Reminder(
      plantId: widget.plant.id!,
      task: 'Tu planta ${plant.name}: ${_taskController.text}',
      frequencyDays: days,
      nextDue: nextDue,
      active: true
    );

    debugPrint('remider $reminder');
    int idReminder = await DatabaseHelper().insertReminder(reminder);
    reminder.id = idReminder;
    Reminder.scheduleNotification(reminder);
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Reminder'), centerTitle: true),
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
            ElevatedButton(
              onPressed: _saveReminder,
              child: const Text('Save Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
