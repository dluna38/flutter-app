import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../helpers/notification_helper.dart'; // Asegúrate de que la ruta sea correcta

class PendingNotificationsScreen extends StatefulWidget {
  const PendingNotificationsScreen({super.key});

  @override
  State<PendingNotificationsScreen> createState() => _PendingNotificationsScreenState();
}

class _PendingNotificationsScreenState extends State<PendingNotificationsScreen> {
  List<PendingNotificationRequest> _pendingNotifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingNotifications();
  }

  Future<void> _loadPendingNotifications() async {
    final notis = await NotificationHelper.getNotis();
    setState(() {
      _pendingNotifications = notis;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificaciones Pendientes'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadPendingNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _pendingNotifications.isEmpty
          ? Center(child: Text('No hay notificaciones pendientes.'))
          : ListView.builder(
        itemCount: _pendingNotifications.length,
        itemBuilder: (context, index) {
          final notification = _pendingNotifications[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(notification.title ?? 'Sin Título'),
              subtitle: Text(notification.body ?? 'Sin Cuerpo'),
              trailing: Text('ID: ${notification.id}'),
              onTap: () {
                // Opcional: mostrar más detalles de la notificación
                _showNotificationDetails(notification);
              },
            ),
          );
        },
      ),
    );
  }

  void _showNotificationDetails(PendingNotificationRequest notification) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detalles de Notificación'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('ID: ${notification.id}'),
                SizedBox(height: 8),
                Text('Título: ${notification.title ?? "N/A"}'),
                SizedBox(height: 8),
                Text('Cuerpo: ${notification.body ?? "N/A"}'),
                SizedBox(height: 8),
                Text('Carga útil (payload): ${notification.payload ?? "N/A"}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}