import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:myapp/data/plant.dart';
import 'package:myapp/helpers/io_helpers.dart';
import 'package:myapp/helpers/string_helpers.dart';

import 'add_care_event_screen.dart';
import 'add_reminder_screen.dart'; // Importa la nueva pantalla

// Definimos los colores para reutilizarlos fácilmente
const Color primaryGreen = Color(0xFF5A8E4C);
const Color darkBackground = Color(0xFF121212);
const Color surfaceColor = Color(0xFF1E1E1E);
const Color lightTextColor = Color(0xFFE0E0E0);
const Color darkTextColor = Color(0xFF8A8A8A);

class PlantDetailScreen extends StatefulWidget {
  final Plant plant;
  const PlantDetailScreen({super.key, required this.plant});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  late final Plant plant;

  @override
  void initState() {
    plant = widget.plant;
    super.initState();
  }

  // Lista para simular los recordatorios activos
  final List<Map<String, String>> _activeReminders = [
    {"reminder": "Revisar humedad de la tierra", "frequency": "3"},
    {"reminder": "Añadir fertilizante líquido", "frequency": "30"},
  ];

  void _removeReminder(int index) {
    setState(() {
      _activeReminders.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: darkBackground,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          _buildContent(),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250.0,
      backgroundColor: primaryGreen,
      pinned: true,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          toBeginningOfSentenceCase(plant.name),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0),
        ),
        background: Image.file(
          File(plant.imagePath ?? IOHelpers.defaultPlaceholder),
          fit: BoxFit.cover,
          colorBlendMode: BlendMode.darken,
          color: Colors.black.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(toBeginningOfSentenceCase(plant.name),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(toBeginningOfSentenceCase(plant.species ?? 'Sin especie indicada'),
                style: TextStyle(color: Colors.grey[400], fontSize: 16)),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 32),
            const Text('Información de la planta',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _InfoRow(label: 'Ubicación', value: plant.location ?? StringHelpers.NO_LOCATION_PLANT),
            _InfoRow(label: 'Date Acquired', value: '31 de julio de 2025'),
            /*_InfoRow(
                label: 'Sunlight Needs', value: 'Partial, indirect sunlight'),
            _InfoRow(
                label: 'Fertilizer\nSchedule',
                value: 'Once a month, during spring\nand summer'),*/
            const SizedBox(height: 32),
            _buildWateringScheduleHeader(),
            const SizedBox(height: 16),
            //_buildSearchBar(),
            const SizedBox(height: 16),
            _ScheduleTile(date: '13 de diciembre de 2025'),
            _ScheduleTile(date: '9 de enero de 2026'),
            const SizedBox(height: 32),

            // --- NUEVA SECCIÓN DE RECORDATORIOS ---
            _buildActiveRemindersHeader(),
            const SizedBox(height: 16),
            _buildRemindersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.edit,
            label: 'Editar Planta',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionButton(
            icon: Icons.add,
            label: 'Riego',
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildWateringScheduleHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Historial de Eventos',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        TextButton.icon(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => AddReminderScreen(plant: plant),
            ));
          },
          icon: const Icon(Icons.add, color: primaryGreen, size: 20),
          label: const Text('Nuevo',
              style:
              TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
          style: TextButton.styleFrom(
            backgroundColor: primaryGreen.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  // --- CABECERA DE LA NUEVA SECCIÓN ---
  Widget _buildActiveRemindersHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recordatorios Activos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddCareEventScreen(plant: plant),
              ),
            );
          },
          icon: const Icon(Icons.add, color: primaryGreen, size: 20),
          label: const Text(
            'Nuevo',
            style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
          ),
          style: TextButton.styleFrom(
            backgroundColor: primaryGreen.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  // --- LISTA DE RECORDATORIOS ACTIVOS ---
  Widget _buildRemindersList() {
    if (_activeReminders.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Center(
          child: Text(
            'No hay recordatorios activos.',
            style: TextStyle(color: darkTextColor, fontSize: 16),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _activeReminders.length,
      itemBuilder: (context, index) {
        final reminder = _activeReminders[index];
        return _ReminderCard(
          reminderText: reminder['reminder']!,
          frequencyDays: reminder['frequency']!,
          onCancel: () => _removeReminder(index),
        );
      },
    );
  }


  Widget _buildSearchBar() {
    return TextField(
      style: const TextStyle(color: lightTextColor),
      decoration: InputDecoration(
        hintText: 'Buscar',
        hintStyle: const TextStyle(color: darkTextColor),
        prefixIcon: const Icon(Icons.search, color: darkTextColor),
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// --- WIDGETS REUTILIZABLES ---

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: darkTextColor, fontSize: 15)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.end,
                style: const TextStyle(color: lightTextColor, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  final String date;
  const _ScheduleTile({required this.date});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      title: const Text('SCHEDULED',
          style: TextStyle(
              color: darkTextColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5)),
      subtitle: Text(date,
          style: const TextStyle(
              color: lightTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: darkTextColor),
      onTap: () {},
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: primaryGreen),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      color: primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}

// --- NUEVO WIDGET PARA LA TARJETA DE RECORDATORIO ---
class _ReminderCard extends StatelessWidget {
  final String reminderText;
  final String frequencyDays;
  final VoidCallback onCancel;

  const _ReminderCard({
    required this.reminderText,
    required this.frequencyDays,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReminderRow('Recuérdame:', reminderText),
          const SizedBox(height: 8),
          _buildReminderRow('Frecuencia:', '$frequencyDays días'),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onCancel,
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: darkTextColor, fontSize: 15)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: lightTextColor, fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}