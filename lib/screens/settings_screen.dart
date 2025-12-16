import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:myapp/helpers/backup_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.backup, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Respaldo',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crea una copia de seguridad de tus plantas, imágenes y datos.',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showBackupDialog(context),
                      icon: const Icon(Icons.save_alt),
                      label: const Text('Crear Respaldo'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _pickAndRestoreBackup(context),
                      icon: const Icon(Icons.restore),
                      label: const Text('Restaurar Respaldo'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        bool includeImages = true;
        bool includeReminders = true;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Opciones de Respaldo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: const Text('Incluir Imágenes'),
                    value: includeImages,
                    onChanged: (value) {
                      setState(() {
                        includeImages = value ?? true;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Incluir Recordatorios'),
                    value: includeReminders,
                    onChanged: (value) {
                      setState(() {
                        includeReminders = value ?? true;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context); // Close dialog first
                    // Show loading indicator or simple snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Generando respaldo...')),
                    );

                    await BackupHelper.createAndShareBackup(
                      includeImages: includeImages,
                      includeReminders: includeReminders,
                    );
                  },
                  child: const Text('Exportar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _pickAndRestoreBackup(BuildContext context) async {
    // 1. Pick File
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);

      if (!context.mounted) return;

      // 2. Confirm Dialog
      bool? confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('⚠️ Restaurar Copia de Seguridad'),
              content: const Text(
                'Esta acción ELIMINARÁ TODOS los datos actuales y los reemplazará con los datos de la copia de seguridad. \n\nEsta acción NO se puede deshacer.',
                style: TextStyle(color: Colors.red),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('RESTAURAR'),
                ),
              ],
            ),
      );

      if (confirm == true) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restaurando respaldo... Por favor espere.'),
          ),
        );

        try {
          await BackupHelper.restoreBackup(file);
          if (!context.mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => AlertDialog(
                  title: const Text('Restauración Exitosa'),
                  content: const Text(
                    'Los datos han sido restaurados correctamente.\n\nPor favor, reinicia la aplicación para aplicar los cambios.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // Close the app to ensure fresh DB reload
                        if (Platform.isAndroid) {
                          SystemNavigator.pop();
                        } else if (Platform.isIOS) {
                          exit(
                            0,
                          ); // exit(0) is not recommended by Apple, but SystemNavigator.pop often does nothing on iOS.
                        } else {
                          exit(0);
                        }
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
          );
        } catch (e) {
          if (!context.mounted) return;
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Error'),
                  content: Text('Error al restaurar: $e'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
          );
        }
      }
    }
  }
}
