import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/care_event.dart';
import '../data/database_helper.dart';
import '../data/plant.dart';
import 'detail_plant_screen.dart';

class CareEventsScreen extends StatefulWidget {
  final Plant plant;

  const CareEventsScreen({super.key, required this.plant});

  @override
  State<CareEventsScreen> createState() => _CareEventsScreenState();
}

class _CareEventsScreenState extends State<CareEventsScreen> {
  late Future<List<CareEvent>> _careEventsFuture;
  final Map<String, String> _filters = {};
  DateTime? _startDate;
  DateTime? _endDate;
  TypeCareEvent? _selectedType;

  @override
  void initState() {
    super.initState();
    _fetchCareEvents();
  }

  // Método para obtener los eventos de la base de datos con filtros
  void _fetchCareEvents() {
    setState(() {
      _careEventsFuture = DatabaseHelper().getCareEvents(
        widget.plant.id!,
        filters: _filters,
      );
    });
  }

  // Método para mostrar el selector de fecha
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      if (isStartDate) {
        _startDate = picked;
        _filters['startDate'] = picked.toIso8601String();
      } else {
        _endDate = picked;
        _filters['endDate'] = picked.toIso8601String();
      }
      _fetchCareEvents();
    }
  }

  // Método para limpiar los filtros de fecha
  void _clearDateFilters() {
    _startDate = null;
    _endDate = null;
    _filters.remove('startDate');
    _filters.remove('endDate');
    _fetchCareEvents();
  }

  void _clearTypeFilter() {
    _selectedType = null;
    _filters.remove('type');
    _fetchCareEvents();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text('Eventos de ${widget.plant.name}')),
      body: Column(
        children: [
          _buildFilterControls(colorScheme),
          Divider(color: colorScheme.primary, thickness: 1.8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: FutureBuilder<List<CareEvent>>(
                future: _careEventsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error al cargar los eventos: ${snapshot.error}',
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No hay eventos registrados.'),
                    );
                  }

                  final events = snapshot.data!;
                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return ScheduleTile(event: events[index]);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterControls(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filtro por tipo de evento (Dropdown)
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<TypeCareEvent>(
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Evento',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  initialValue: _selectedType,
                  onChanged: (TypeCareEvent? newValue) {
                    _selectedType = newValue;
                    if (newValue != null) {
                      _filters['type'] = newValue.index.toString();
                    } else {
                      _filters.remove('type');
                    }
                    _fetchCareEvents();
                  },
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    ...TypeCareEvent.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.normalName),
                      );
                    }),
                  ],
                ),
              ),
              if (_selectedType != null)
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.red),
                  onPressed: _clearTypeFilter,
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Filtros de fecha
          Row(
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _selectDate(context, true),
                  child: Text(
                    _startDate == null
                        ? 'Fecha de inicio'
                        : DateFormat.yMMMd().format(_startDate!),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _selectDate(context, false),
                  child: Text(
                    _endDate == null
                        ? 'Fecha de fin'
                        : DateFormat.yMMMd().format(_endDate!),
                  ),
                ),
              ),
              if (_startDate != null || _endDate != null)
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.red),
                  onPressed: _clearDateFilters,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
