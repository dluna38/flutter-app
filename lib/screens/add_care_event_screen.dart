import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/data/care_event.dart';
import 'package:myapp/data/database_helper.dart';
import 'package:myapp/data/plant.dart';

class AddCareEventScreen extends StatefulWidget {
  final Plant plant;
  final CareEvent? careEvent;

  const AddCareEventScreen({super.key, required this.plant, this.careEvent});

  @override
  State<AddCareEventScreen> createState() => _AddCareEventScreenState();
}

class _AddCareEventScreenState extends State<AddCareEventScreen> {
  late Plant plant;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay(
    hour: DateTime.now().hour,
    minute: DateTime.now().minute,
  );
  final TextEditingController _notesController = TextEditingController();
  TypeCareEvent selectedTypeEvent = TypeCareEvent.riego;

  @override
  void initState() {
    super.initState();
    plant = widget.plant;
    if (widget.careEvent != null) {
      _selectedDate = widget.careEvent!.date;
      _selectedTime = TimeOfDay.fromDateTime(widget.careEvent!.date);
      selectedTypeEvent = widget.careEvent!.type;
      _notesController.text = widget.careEvent!.notes ?? '';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: _selectedDate,
    );
    if (picked != null && picked != _selectedDate) {
      debugPrint('Guardar: $picked');
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.dial,
      initialTime: TimeOfDay.now(),
      /*builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },*/
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      debugPrint('Guardar: $pickedTime');
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar evento'),
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
          children: <Widget>[
            Row(
              children: [
                Text(
                  'Fecha: ${DateFormat('dd-MM-yyyy').format(_selectedDate)}',
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Hora: ${_selectedTime.format(context)}',
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.timer_sharp),
                  onPressed: () => _selectTime(context),
                ),
              ],
            ),
            const Text('Tipo'),
            Wrap(
              spacing: 8.0,
              children:
                  TypeCareEvent.values.map((TypeCareEvent type) {
                    return ChoiceChip(
                      label: Text(type.normalName),
                      avatar: Icon(type.icon, size: 18),
                      selected: selectedTypeEvent == type,
                      showCheckmark: false,
                      onSelected: (bool selected) {
                        if (selected) {
                          setState(() {
                            selectedTypeEvent = type;
                          });
                        }
                      },
                    );
                  }).toList(),
            ),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 20),
            const Spacer(),
            // Botón para guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final eventDate = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    _selectedTime.hour,
                    _selectedTime.minute,
                  );

                  if (widget.careEvent != null) {
                    // Update existing
                    widget.careEvent!.date = eventDate;
                    widget.careEvent!.type = selectedTypeEvent;
                    widget.careEvent!.notes =
                        _notesController.text.isEmpty
                            ? null
                            : _notesController.text;
                    widget.careEvent!.plant ??=
                        plant; // Ensure plant is set if missing

                    await DatabaseHelper().updateCareEvent(widget.careEvent!);
                  } else {
                    // Create new
                    final newCareEvent = CareEvent(
                      date: eventDate,
                      type: selectedTypeEvent,
                      notes:
                          _notesController.text.isEmpty
                              ? null
                              : _notesController.text,
                      plant: plant,
                    );
                    await DatabaseHelper().insertCareEvent(
                      newCareEvent,
                      widget.plant.id!,
                    );
                  }

                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.careEvent != null
                      ? 'Actualizar evento'
                      : 'Guardar evento',
                  style: const TextStyle(
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

class SegmentedButtonTypeEvent extends StatefulWidget {
  final TypeCareEvent chooseType;

  const SegmentedButtonTypeEvent({super.key, required this.chooseType});

  @override
  State<StatefulWidget> createState() => _SegmentedButtonTypeEventState();
}

class _SegmentedButtonTypeEventState extends State<SegmentedButtonTypeEvent> {
  late TypeCareEvent _selectedType = widget.chooseType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.chooseType;
  }

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TypeCareEvent>(
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
      selected: <TypeCareEvent>{_selectedType},
      onSelectionChanged: (Set<TypeCareEvent> newSelection) {
        setState(() {
          _selectedType = newSelection.first;
        });
      },
    );
  }
}
