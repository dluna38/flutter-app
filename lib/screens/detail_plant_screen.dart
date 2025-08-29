import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:myapp/data/care_event.dart';
import 'package:myapp/data/database_helper.dart';
import 'package:myapp/data/plant.dart';
import 'package:myapp/data/reminder.dart';
import 'package:myapp/helpers/io_helpers.dart';
import 'package:myapp/helpers/my_app_style.dart';
import 'package:myapp/helpers/string_helpers.dart';
import 'package:myapp/screens/add_plant_screen.dart';

import 'add_care_event_screen.dart';
import 'add_reminder_screen.dart';
import 'full_care_event_list_screen.dart';
import 'package:myapp/main.dart';
// Definimos los colores para reutilizarlos fácilmente

class PlantDetailScreen extends StatefulWidget {
  final Plant plant;
  final NotificationResponse? notiResponse;
  const PlantDetailScreen({super.key, required this.plant, this.notiResponse});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  late Plant plant;
  late Future<List<CareEvent>> _careEventsFuture;
  late Future<List<Reminder>> _remindersFuture;
  List<Reminder> loadedReminders = [];
  bool iconRegado = false;
  bool plantUpdated = false;
  @override
  void initState() {
    super.initState();
    plant = widget.plant;
    if (widget.notiResponse != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAlertDialogFromNotification(widget.notiResponse!);
      });
    }
    updateCareEventsDataset();
    _remindersFuture = DatabaseHelper().getReminders(plant.id!);
  }

  void showAlertDialogFromNotification(NotificationResponse notiResponse) {
    final payload = jsonDecode(notiResponse.payload!);
    final String body = payload['body'] ?? '';
    final BuildContext? context = navigatorKey.currentContext;
    if (context == null) {
      debugPrint('context null');
      return;
    }
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    debugPrint('show dialog');
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.yard_outlined, color: Colors.green),
              SizedBox(width: 8),
              Text('Recordatorio'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('¡Es hora de cuidar una de tus plantas! 🌿'),
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  text: 'Recordatorio: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: body.split(':')[1],
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        );
      },
    );
  }

  void updateCareEventsDataset() {
    _careEventsFuture = DatabaseHelper().getCareEvents(
      plant.id!,
      filters: {"limit": "5"},
    );
  }

  void _removeReminder(int index) {
    Reminder reminder = loadedReminders[index];
    reminder.delete();
    //_remindersFuture = DatabaseHelper().getReminders(plant.id!);
    setState(() {
      loadedReminders.removeAt(index);
    });
  }

  void _deletePlant() {
    DatabaseHelper().deletePlant(plant.id!);
    Navigator.pop(context, PlantResult(updated: true));
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && context.mounted) {
          Navigator.pop(context, PlantResult(updated: plantUpdated));
        }
      },
      child: Scaffold(
        //backgroundColor: colorScheme.surface,
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(colorScheme),
            _buildContent(colorScheme),
          ],
        ),
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
          Navigator.pop(context, PlantResult(updated: plantUpdated));
        },
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
          onSelected: (value) {
            if (value == 'delete') {
              _deletePlant();
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Borrar planta'),
                ),
              ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          toBeginningOfSentenceCase(plant.name),
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        background:
            plant.imagePath != null
                ? Image.file(
                  File(plant.imagePath ?? IOHelpers.defaultPlaceholder),
                  fit: BoxFit.cover,
                  colorBlendMode: BlendMode.darken,
                  color: Colors.black.withValues(alpha: 0.4),
                )
                : Image.asset(
                  IOHelpers.getImagePlaceHolderString(),
                  fit: BoxFit.cover,
                  colorBlendMode: BlendMode.darken,
                  color: Colors.black.withValues(alpha: 0.4),
                ),
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
            Text(
              toBeginningOfSentenceCase(plant.name),
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              toBeginningOfSentenceCase(
                plant.species ?? 'Sin especie indicada',
              ),
              style: TextStyle(
                color: MyAppStyle.lightTextColorLight,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 32),
            Text(
              'Información de la planta',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: 'Ubicación',
              value: plant.location ?? StringHelpers.NO_LOCATION_PLANT,
            ),
            _InfoRow(
              label: 'Fecha de adquisición',
              value: StringHelpers.formatLocalDate(
                plant.acquisitionDate,
                context,
                format: 'dd/MM/yyyy',
              ),
            ),
            plant.notes != null ? Column(
              children: [
                Center(
                  child: Text("Notas", style: TextStyle(color: colorScheme.onSurface, fontSize: 15),),
                ),
                const SizedBox(height: 8,),
                SizedBox(height: 120, child: SingleChildScrollView(child: Text(plant.notes! ,style: TextStyle(color: colorScheme.onSurface, fontSize: 15),)))
              ],
            ) : SizedBox.shrink(),
            const SizedBox(height: 32),
            _buildEventsHeader(colorScheme),

            //const SizedBox(height: 16),
            _buildEventsList(colorScheme),
            const SizedBox(height: 24),

            // --- SECCIÓN DE RECORDATORIOS ---
            _buildActiveRemindersHeader(colorScheme),
            //const SizedBox(height: 8),
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
            onTap: () async {
              PlantResult? result = await Navigator.push<PlantResult>(
                context,
                MaterialPageRoute<PlantResult>(
                  builder: (context) => AddPlantScreen(updatePlant: plant),
                ),
              );

              if (result != null && result.updated) {
                Plant? freshPlant = await DatabaseHelper().getPlantById(
                  plant.id!,
                );
                if (freshPlant != null) {
                  setState(() {
                    plantUpdated = true;
                    plant = freshPlant;
                  });
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Planta actualizada con éxito!'),
                    ),
                  );
                }
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionButton(
            icon: iconRegado ? Icons.water_drop : Icons.opacity,
            label: iconRegado ? 'Regado' : 'Regar',
            onTap: () async {
              if (iconRegado) {
                return;
              }
              await DatabaseHelper().insertCareEvent(
                CareEvent.createNow(plant, TypeCareEvent.riego),
                plant.id!,
              );
              updateCareEventsDataset();
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
        Text(
          'Eventos',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton.icon(
          onPressed: () async {
            bool? result = await Navigator.push<bool>(
              context,
              MaterialPageRoute<bool>(
                builder: (context) => AddCareEventScreen(plant: plant),
              ),
            );
            //se actualiza sin importar que el usuario cancele el agregado
            if (result == null || result) {
              setState(() {
                updateCareEventsDataset();
              });
            }
          },
          icon: Icon(Icons.add, color: colorScheme.primary, size: 20),
          label: Text(
            'Nuevo',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
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
          return Center(
            child: Text('Error al cargar los eventos: ${snapshot.error}'),
          );
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

        return Column(
          children: [
            ListView.builder(
              itemCount: events.length,
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // Para evitar scroll anidado
              itemBuilder: (context, index) {
                return ScheduleTile(event: events[index]);
              },
            ),
            if (events.length == 5)
              Align(
                alignment: Alignment.centerRight,
                child: _ActionButton(
                  icon: null,
                  label: 'Ver más',
                  onTap:
                      () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => CareEventsScreen(plant: plant),
                          ),
                        ),
                      },
                ),
              ),
          ],
        );
      },
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
            bool? result = await Navigator.push<bool>(
              context,
              MaterialPageRoute<bool>(
                builder: (context) => AddReminderScreen(plant: plant),
              ),
            );

            if (result != null && result) {
              setState(() {
                _remindersFuture = DatabaseHelper().getReminders(plant.id!);
              });
            }
          },
          icon: Icon(Icons.add, color: colorScheme.primary, size: 20),
          label: Text(
            'Nuevo',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
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
          return Center(
            child: Text('Error al cargar los recordatorios: ${snapshot.error}'),
          );
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
              reminder: reminder,
              onCancel:
                  () => _showDeleteReminderConfirmationDialog(context, index),
            );
          },
        );
      },
    );
  }

  void _showDeleteReminderConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Borrar Recordatorio"),
          content: const Text("¿Estás seguro de eliminar el recordatorio?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                _removeReminder(index);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Borrar"),
            ),
          ],
        );
      },
    );
  }
}

class ScheduleTile extends StatelessWidget {
  final CareEvent event;

  const ScheduleTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      leading: Icon(
        _getEventTypeIcon(event.type),
        color: colorScheme.primary,
      ), // Opcional: un icono
      title: Text(
        'Evento: ${event.type.normalName}',
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      subtitle: Text(
        StringHelpers.formatLocalDate(event.date, context),
        style: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.7),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      /*trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.onSurface.withValues(alpha: 0.5),
      ),*/
    );
  }

  IconData _getEventTypeIcon(TypeCareEvent type) {
    switch (type) {
      case TypeCareEvent.riego:
        return Icons.water_drop_outlined;
      case TypeCareEvent.fertilizante:
        return Icons.compost;
      case TypeCareEvent.poda:
        return Icons.content_cut;
      case TypeCareEvent.cambioAbono:
        return Icons.compost;
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
    if (value == null) {
      return SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: colorScheme.onSurface, fontSize: 15),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value!,
              textAlign: TextAlign.end,
              style: TextStyle(color: colorScheme.onSurface, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({this.icon, required this.label, required this.onTap});

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
              if (icon != null) Icon(icon, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onCancel;

  const _ReminderCard({required this.reminder, required this.onCancel});

  DateTime calcNextDue(DateTime date) {
    return reminder.nextDue.isBefore(DateTime.now())
        ? date.add(Duration(days: reminder.frequencyDays))
        : date;
  }

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
          _buildReminderRow('Recuérdame:', reminder.task, context),
          const SizedBox(height: 8),
          _buildReminderRow(
            'Frecuencia:',
            '${reminder.frequencyDays} días',
            context,
          ),
          const SizedBox(height: 8),
          _buildReminderRow(
            'Próximo:',
            StringHelpers.formatLocalDate(
              calcNextDue(reminder.nextDue),
              context,
            ),
            context,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
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

  Widget _buildReminderRow(String label, String value, BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: colorScheme.onSurface, fontSize: 15),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
