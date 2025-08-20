import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/data/care_event.dart';
import 'package:myapp/data/database_helper.dart';
import 'package:myapp/data/plant.dart';
import 'package:myapp/data/reminder.dart';
import 'package:myapp/helpers/io_helpers.dart';
import 'package:myapp/helpers/my_app_style.dart';
import 'package:myapp/helpers/string_helpers.dart';

import 'add_care_event_screen.dart';
import 'add_reminder_screen.dart';
// Definimos los colores para reutilizarlos fácilmente

class PlantDetailScreen extends StatefulWidget {
  final Plant plant;
  const PlantDetailScreen({super.key, required this.plant});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  late final Plant plant;
  late Future<List<CareEvent>> _careEventsFuture;
  late Future<List<Reminder>> _remindersFuture;
  List<Reminder> loadedReminders = [];
  bool iconRegado=false;
  @override
  void initState() {
    super.initState();
    plant = widget.plant;
    _careEventsFuture = DatabaseHelper().getCareEvents(plant.id!);
    _remindersFuture = DatabaseHelper().getReminders(plant.id!);
  }

  void _removeReminder(int index) {
    Reminder reminder = loadedReminders[index];
    reminder.delete();
    _remindersFuture = DatabaseHelper().getReminders(plant.id!);
    setState(() {
      loadedReminders.removeAt(index);
    });

  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      //backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(colorScheme),
          _buildContent(colorScheme),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 250.0,
      backgroundColor: colorScheme.surface,
      pinned: true,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          toBeginningOfSentenceCase(plant.name),
          style: TextStyle(
              color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16.0),
        ),
        background: plant.imagePath != null ? Image.file(
          File(plant.imagePath ?? IOHelpers.defaultPlaceholder),
          fit: BoxFit.cover,
          colorBlendMode: BlendMode.darken,
          color: Colors.black.withValues(alpha: 0.4),
        ): Image.asset(IOHelpers.getImagePlaceHolderString(),fit: BoxFit.cover,
          colorBlendMode: BlendMode.darken,
          color: Colors.black.withValues(alpha: 0.4),),
      ),
    );
  }

  Widget _buildContent(ColorScheme colorScheme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(toBeginningOfSentenceCase(plant.name),
                style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(toBeginningOfSentenceCase(plant.species ?? 'Sin especie indicada'),
                style: TextStyle(color: MyAppStyle.lightTextColorLight, fontSize: 16)),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 32),
            Text('Información de la planta',
                style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _InfoRow(label: 'Ubicación', value: plant.location ?? StringHelpers.NO_LOCATION_PLANT),
            _InfoRow(label: 'Fecha de adquisición', value: StringHelpers.formatLocalDate(plant.acquisitionDate, context,format: 'dd/MM/yyyy')),
            _InfoRow(label: 'Notas', value: plant.notes),
            /*_InfoRow(
                label: 'Sunlight Needs', value: 'Partial, indirect sunlight'),
            _InfoRow(
                label: 'Fertilizer\nSchedule',
                value: 'Once a month, during spring\nand summer'),*/
            const SizedBox(height: 32),
            _buildEventsHeader(colorScheme),
            const SizedBox(height: 16),
            //_buildSearchBar(),
            //const SizedBox(height: 16),
            _buildEventsList(colorScheme),
            const SizedBox(height: 24),

            // --- SECCIÓN DE RECORDATORIOS ---
            _buildActiveRemindersHeader(colorScheme),
            //const SizedBox(height: 16),
            _buildRemindersList(colorScheme),
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
            icon: iconRegado ? Icons.water_drop:Icons.opacity,
            label: iconRegado? 'Regado':'Regar',
            onTap: () async {
              if(iconRegado){
                return;
              }
              await DatabaseHelper().insertCareEvent(CareEvent.createNow(plant, TypeCareEvent.riego), plant.id!);
              _careEventsFuture = DatabaseHelper().getCareEvents(plant.id!);
              setState(() {
                iconRegado = true;
              });

              /*
              TODO
              change icon Icons.water_drop and text: Regado and disable button
               */
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventsHeader(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Eventos',
            style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        TextButton.icon(
          onPressed:  () async {
            bool? result = await Navigator.push<bool>(context, MaterialPageRoute<bool>(
              builder: (context) => AddCareEventScreen(plant: plant),
            ));
            //se actualiza sin importar que el usuario cancele el agregado
            if(result == null || result){
              setState(() {
                _careEventsFuture = DatabaseHelper().getCareEvents(plant.id!);
              });
            }
          },
          icon:  Icon(Icons.add, color: colorScheme.primary, size: 20),
          label:  Text('Nuevo',
              style:
              TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
          style: TextButton.styleFrom(
            backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  // --- CABECERA DE LA NUEVA SECCIÓN ---
  Widget _buildActiveRemindersHeader(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
         Text(
          'Recordatorios Activos',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton.icon(
          onPressed: () async {
            bool? result = await Navigator.push<bool>(context, MaterialPageRoute<bool>(
              builder: (context) => AddReminderScreen(plant: plant),
            ));
            //se actualiza sin importar que el usuario cancele el agregado
            if(result == null || result){
              setState(() {
                _remindersFuture = DatabaseHelper().getReminders(plant.id!);
              });
            }
          },
          icon:  Icon(Icons.add, color: colorScheme.primary, size: 20),
          label:  Text(
            'Nuevo',
            style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
          ),
          style: TextButton.styleFrom(
            backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  // --- LISTA DE RECORDATORIOS ACTIVOS ---
  Widget _buildRemindersList(ColorScheme colorScheme) {
    return FutureBuilder<List<Reminder>>(
      future: _remindersFuture, // El Future que creamos en initState
      builder: (context, snapshot) {
        // ESTADO 1: Cargando los datos
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // ESTADO 2: Ocurrió un error
        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar los recordatorios: ${snapshot.error}'));
        }

        // ESTADO 3: Datos cargados, pero la lista está vacía
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: Text(
                'No hay recordatorios activos.',
                style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
              ),
            ),
          );
        }

        // ESTADO 4: Datos cargados exitosamente
        loadedReminders = snapshot.data!;
        
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: loadedReminders.length,
          itemBuilder: (context, index) {
            final reminder = loadedReminders[index];
            return _ReminderCard(
              reminderText: reminder.task,
              frequencyDays: '${reminder.frequencyDays}',
              onCancel: () => _removeReminder(index),
            );
          },
        );
      },
    );
  }


  Widget _buildSearchBar(ColorScheme colorScheme) {
    return TextField(
      style:  TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: 'Buscar',
        hintStyle:  TextStyle(color: colorScheme.inversePrimary),
        prefixIcon:  Icon(Icons.search, color: colorScheme.inversePrimary),
        filled: true,
        //fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildEventsList(ColorScheme colorScheme) {
    return FutureBuilder<List<CareEvent>>(
      future: _careEventsFuture, // El Future que creamos en initState
      builder: (context, snapshot) {
        // ESTADO 1: Cargando los datos
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // ESTADO 2: Ocurrió un error
        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar los eventos: ${snapshot.error}'));
        }

        // ESTADO 3: Datos cargados, pero la lista está vacía
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
              'No hay eventos registrados.',
              style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
            ),
            ),
          );
        }

        // ESTADO 4: Datos cargados exitosamente
        final events = snapshot.data!;
        // Usamos ListView.builder para construir la lista dinámicamente
        return ListView.builder(
          itemCount: events.length,
          shrinkWrap: true, // Importante dentro de un CustomScrollView
          physics: const NeverScrollableScrollPhysics(), // Para evitar scroll anidado
          itemBuilder: (context, index) {
            final event = events[index];
            // Pasamos el objeto completo al widget _ScheduleTile refactorizado
            return _ScheduleTile(event: event);
          },
        );
      },
    );
  }
}
class _ScheduleTile extends StatelessWidget {
  final CareEvent event;

  const _ScheduleTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      leading: Icon(_getEventTypeIcon(event.type), color: colorScheme.primary), // Opcional: un icono
      title: Text(
        'Evento: ${event.type.normalName}',
        style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5),
      ),
      subtitle: Text(
        StringHelpers.formatLocalDate(event.date, context),
        style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 16,
            fontWeight: FontWeight.w500),
      ),
      trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface.withValues(alpha: 0.5)),
      onTap: () {
        // Aquí puedes navegar a una pantalla de detalle del evento si lo deseas
        // Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)));
      },
    );
  }

  // (Opcional) Helper para obtener un icono según el tipo de evento
  IconData _getEventTypeIcon(TypeCareEvent type) {
    switch (type) {
      case TypeCareEvent.riego:
        return Icons.water_drop_outlined;
      case TypeCareEvent.fertilizante:
        return Icons.eco_outlined;
      case TypeCareEvent.poda:
        return Icons.content_cut;
      default:
        return Icons.yard_outlined;
    }
  }
}
// --- WIDGETS REUTILIZABLES ---

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    if(value == null){
      return SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:  TextStyle(color: colorScheme.onSurface, fontSize: 15)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value!,
                textAlign: TextAlign.end,
                style:  TextStyle(color: colorScheme.onSurface, fontSize: 15)),
          ),
        ],
      ),
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.primary.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(label,
                  style:  TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}

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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReminderRow('Recuérdame:', reminderText,context),
          const SizedBox(height: 8),
          _buildReminderRow('Frecuencia:', '$frequencyDays días',context),
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

  Widget _buildReminderRow(String label, String value,BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style:  TextStyle(color: colorScheme.onSurface, fontSize: 15)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style:  TextStyle(color: colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}