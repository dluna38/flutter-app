import 'package:flutter/material.dart';
import 'package:myapp/data/database_helper.dart';
import 'package:sqflite/sqflite.dart';
// Asegúrate de importar tu clase de base de datos
// Por ejemplo: import 'package:mi_app/database/database_helper.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  List<Map<String, dynamic>> _logEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Reemplaza esto con tu método real para obtener logs de la DB
      // Por ejemplo: final logs = await DatabaseHelper.instance.getLogs();
      final logs = await DatabaseHelper().getLogs(); // Suponiendo esta función
      setState(() {
        _logEntries = logs;
      });
    } catch (e) {
      // Manejo de errores
      debugPrint('Error al cargar los logs: $e');
      setState(() {
        _logEntries = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logs de la Aplicación'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadLogs, // Llama al método de carga cuando se presiona
          ),
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: () {
              // Lógica para borrar todos los logs de la DB
              // Por ejemplo: await DatabaseHelper.instance.clearLogs();
              setState(() {
                _logEntries.clear();
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _logEntries.isEmpty
          ? Center(child: Text('No hay logs disponibles.'))
          : ListView.builder(
        itemCount: _logEntries.length,
        itemBuilder: (context, index) {
          final log = _logEntries[index];
          final timestamp = DateTime.fromMillisecondsSinceEpoch(log['timestamp']);
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: ListTile(
              title: Text(log['message'] ?? 'Mensaje Nulo'),
              subtitle: Text('${log['level']} - ${timestamp.toString()}'),
            ),
          );
        },
      ),
    );
  }
}