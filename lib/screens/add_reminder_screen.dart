import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/care_event.dart';
import '../data/plant.dart';
import '../data/database_helper.dart';
import '../data/reminder.dart';
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
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay(hour: 9, minute: 0);
  TypeCareEvent? _selectedTypeEvent;
  final DateTime currentDate = DateTime.now();
  late DateTime _selectedDate = currentDate.add(Duration(days: 1));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    plant = widget.plant;
    _daysController.text = "1";
  }

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: _selectedDate,
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      debugPrint('Guardar: $picked');
      setState(() {
        _selectedDate = picked;
      });
    }
  }


  void showAlertDialogSave(BuildContext context) {
    if (_taskController.text.trim().isEmpty) {
      showMessenger(context,'Por favor, ingresa qué recordar.');
      return;
    }
    int? days = int.tryParse(_daysController.text);
    if (days == null || days < 1) {
      showMessenger(context,'Por favor, ingresa un número válido de días.');
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Creación de recordatorio"),
          content: Text(
            "El recordatorio de: ${_taskController.text} iniciara el ${DateFormat('dd/MM/yyyy').format(_selectedDate)} a las ${_selectedTime.format(context)} y se repetirá cada ${_daysController.text} ${_daysController.text == "1" ? 'dia' : 'dias'}",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
                _saveReminder(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  void showMessenger(BuildContext context,String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _saveReminder(BuildContext context) async {
    int? days = int.tryParse(_daysController.text);
    //DateTime nextDue = _selectedDate.copyWith(minute: _selectedTime.minute,hour: _selectedTime.hour);
    DateTime nextDue = currentDate.add(Duration(minutes: 3));

    Reminder reminder = Reminder(
      plantId: widget.plant.id!,
      task: 'Planta ${plant.name}: ${_taskController.text}',
      frequencyDays: days!,
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
              selected:
                  _selectedTypeEvent != null
                      ? <TypeCareEvent>{_selectedTypeEvent!}
                      : <TypeCareEvent>{},
              onSelectionChanged: (Set<TypeCareEvent> newSelection) {
                setState(() {
                  if (newSelection.isEmpty) {
                    _selectedTypeEvent = null;
                    _taskController.text = '';
                  } else {
                    _selectedTypeEvent = newSelection.first;

                    _taskController.text = _selectedTypeEvent!.normalName;
                  }
                });
              },
            ),
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(labelText: 'Que recordar?'),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Text(
                  'Fecha de inicio: ${DateFormat('dd-MM-yyyy').format(_selectedDate)}',
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextField(
              keyboardType: TextInputType.number,
              controller: _daysController,
              decoration: const InputDecoration(
                labelText: 'Repetir cada tantos dias:',
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
                  showAlertDialogSave(context);
                  // _saveReminder(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Guardar recordatorio',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
