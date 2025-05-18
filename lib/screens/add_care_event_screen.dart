import 'package:flutter/material.dart';
import 'package:myapp/data/care_event.dart';
import 'package:myapp/data/database_helper.dart';
import 'package:myapp/data/plant.dart';

class AddCareEventScreen extends StatefulWidget {
  final Plant plant;

  const AddCareEventScreen({super.key, required this.plant});

  @override
  State<AddCareEventScreen> createState() => _AddCareEventScreenState();
}

class _AddCareEventScreenState extends State<AddCareEventScreen> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         leading: Icon(
          Icons.emoji_nature,
        ),
        title: const Text('Add Care Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Text(
                  'Date: ${_selectedDate.toLocal()}'.split(' ')[0],
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final newCareEvent = CareEvent(
                  date: _selectedDate,
                  type: _typeController.text,
                  notes: _notesController.text,
                );
                await DatabaseHelper().insertCareEvent(newCareEvent,widget.plant.id!);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}