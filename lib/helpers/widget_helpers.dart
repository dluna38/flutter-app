
import 'package:flutter/material.dart';
import 'package:myapp/main.dart';

class WidgetHelpers{

  static void showAlertDialog({String title ="Información",String body ="sin contenido"}){
    BuildContext? context = navigatorKey.currentContext;
    if(context == null){
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('¡Es hora de cuidar una de tus plantas! 🌿'),
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
}