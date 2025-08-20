import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:myapp/helpers/notification_helper.dart';
import '../data/care_event.dart';
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
  TypeCareEvent? _selectedTypeEvent;

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

  void _saveReminder(BuildContext context) async {
    // Valida que el campo de tarea no esté vacío
    if (_taskController.text.trim().isEmpty) {
      // Muestra un mensaje al usuario si el campo está vacío
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa qué recordar.')),
      );
      return;
    }

    int? days = int.tryParse(_daysController.text);
    if (days == null || days < 1) {
      // Muestra un mensaje al usuario si los días no son válidos
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un número válido de días.')),
      );
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
        Navigator.pop(context, true);
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
      appBar: AppBar(
        title: const Text('Agregar recordatorio'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<TypeCareEvent>(
              segments: const <ButtonSegment<TypeCareEvent>>[
                ButtonSegment<TypeCareEvent>(
                  value: TypeCareEvent.riego,
                  label: Text('Riego'),
                  icon: Icon(Icons.water_drop),
                ),
                ButtonSegment<TypeCareEvent>(
                  value: TypeCareEvent.fertilizante,
                  label: Text('Fertilizante'),
                  icon: Icon(Icons.grain),
                ),
                ButtonSegment<TypeCareEvent>(
                  value: TypeCareEvent.poda,
                  label: Text('Poda'),
                  icon: Icon(Icons.cut),
                ),
                ButtonSegment<TypeCareEvent>(
                  value: TypeCareEvent.cambioAbono,
                  label: Text('C. tierra'),
                  icon: Icon(Icons.energy_savings_leaf),
                ),
              ],
              emptySelectionAllowed: true,
              selected: _selectedTypeEvent != null ? <TypeCareEvent>{_selectedTypeEvent!} : <TypeCareEvent>{},
              onSelectionChanged: (Set<TypeCareEvent> newSelection) {
                setState(() {
                  if (newSelection.isEmpty) {
                    _selectedTypeEvent = null; // No hay selección
                    _taskController.text = ''; // Borra el texto del TextField
                  } else {
                    _selectedTypeEvent = newSelection.first; // Establece la nueva selección
                    // Actualiza el texto del TextField según la selección
                    _taskController.text = _selectedTypeEvent!.normalName;
                  }
                });
              },
            ),
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
                  _saveReminder(context);
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
