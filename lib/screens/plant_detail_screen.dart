import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:myapp/data/database_helper.dart';
import 'package:myapp/data/care_event.dart';
import 'package:myapp/data/plant.dart';
import 'package:myapp/data/reminder.dart';
import 'package:myapp/screens/add_care_event_screen.dart';
import 'package:myapp/screens/add_reminder_screen.dart';
import 'package:myapp/screens/plant_list_screen.dart';

import '../main.dart';

class PlantDetailScreen extends StatelessWidget {
  final Plant plant;

  const PlantDetailScreen({super.key, required this.plant});

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  void _showDeleteCareEventConfirmationDialog(
    BuildContext context,
    CareEvent careEvent,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Care Event"),
          content: const Text(
            "Are you sure you want to delete this care event?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await DatabaseHelper().deleteCareEvent(careEvent.id!);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteReminderConfirmationDialog(
    BuildContext context,
    Reminder reminder,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Reminder"),
          content: const Text("Are you sure you want to delete this reminder?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await DatabaseHelper().deleteReminder(reminder.id!);
                //refresh the list of reminders
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Borrar planta"),
          content: const Text("Seguro que deseas eliminarla?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                DatabaseHelper().deletePlant(plant.id!);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
              child: const Text("Borrar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[300],
        title: Text(toBeginningOfSentenceCase(plant.name)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (plant.imagePath != null)
              Image.file(
                File(plant.imagePath!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            else
              const SizedBox(),
            const SizedBox(height: 16),
            Text(
              'Species: ${plant.species}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Location: ${plant.location}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text('Notes: ${plant.notes}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _showDeleteConfirmationDialog(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Borrar Planta"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddCareEventScreen(plant: plant),
                  ),
                );
              },
              child: const Text("Add Care Event"),
            ),
            const SizedBox(height: 16),
            const Text('Care Events:', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            if (plant.careEvents.isEmpty)
              const Text("No care events added yet.")
            else
              ...plant.careEvents.map((CareEvent event) {
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_formatDate(event.date)} - ${event.type.normalName}: ${event.notes}',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _showDeleteCareEventConfirmationDialog(context, event);
                      },
                    ),
                  ],
                );
              }),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddReminderScreen(plant: plant),
                  ),
                );
              },
              child: const Text("Add Reminder"),
            ),
            const SizedBox(height: 16),
            const Text('Reminders:', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            if (plant.reminders.isEmpty)
              const Text("No reminders added yet.")
            else
              ...plant.reminders.map(
                (Reminder reminder) => Text(
                  '${reminder.task} - ${reminder.frequency} - ${reminder.nextDue}',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
