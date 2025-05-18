import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/plant.dart';
import '../data/database_helper.dart';
import '../data/reminder.dart';

class AddReminderScreen extends StatefulWidget {
  final Plant plant;

  const AddReminderScreen({super.key, required this.plant});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final TextEditingController _taskController = TextEditingController();
  String _selectedFrequency = 'daily';
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveReminder() async {
    DateTime nextDue = _selectedDate;
    if (_selectedFrequency == 'daily') {
      nextDue = _selectedDate.add(const Duration(days: 1));
    } else if (_selectedFrequency == 'weekly') {
      nextDue = _selectedDate.add(const Duration(days: 7));
    } else if (_selectedFrequency == 'monthly') {
      nextDue = DateTime(_selectedDate.year, _selectedDate.month + 1, _selectedDate.day);
    }

    final dbHelper = DatabaseHelper();
    Reminder reminder = Reminder(
      plantId: widget.plant.id!,
      task: _taskController.text,
      frequency: _selectedFrequency,
      nextDue: nextDue,
    );
    await dbHelper.insertReminder(reminder);
    if(context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Reminder'),
        leading: const Icon(Icons.local_florist),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(labelText: 'Task'),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedFrequency,
              items: ['daily', 'weekly', 'monthly']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFrequency = newValue!;
                });
              },
              decoration: const InputDecoration(labelText: 'Frequency'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Start Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Select Date'),
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