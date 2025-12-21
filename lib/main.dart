import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:myapp/data/reminder.dart';
import 'package:myapp/helpers/my_app_style.dart';
import 'package:myapp/helpers/string_helpers.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:workmanager/workmanager.dart';

import 'data/database_helper.dart';
import 'helpers/notification_helper.dart';
import 'screens/add_plant_screen.dart';
import 'screens/plant_list_screen.dart';
import 'screens/settings_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  NotificationHelper.initNotifications();
  // Obtener los detalles de lanzamiento de la aplicación
  NotificationHelper().checkLaunchDetails();

  Workmanager().initialize(callbackDispatcher);
  Workmanager().cancelAll();
  Workmanager().registerPeriodicTask(
    'schedule-reminder',
    'task-schedule-reminder',
    frequency: Duration(hours: 24),
    initialDelay: Duration(seconds: 10),
    existingWorkPolicy: ExistingWorkPolicy.replace,
  );

  initializeDateFormatting();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'PlantApp',
      theme: MyAppStyle.lightTheme,
      darkTheme: MyAppStyle.darkTheme,
      themeMode: ThemeMode.system,
      routes: {
        '/': (context) => const HomeScreen(),
        '/add_plant': (context) => const AddPlantScreen(),
        '/plant_list': (context) => const PlantListScreen(),
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: <Locale>[
        const Locale('es', 'US') /*const Locale('en', 'US')*/,
      ],
      locale: Locale('es', 'US'),
      /*localeResolutionCallback: (locale, supportedLocales) {
        if (supportedLocales.contains(locale)) {
          return locale;
        }
        return const Locale('es', ''); // Idioma por defecto
      },*/
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Key _plantListKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: const Icon(Icons.eco),
        title: Text(
          "Mis plantas",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
              // Refresh plant list to apply any view mode changes
              setState(() {
                _plantListKey = UniqueKey();
              });
            },
          )
        ],
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () async {
          PlantResult? result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPlantScreen()),
          );

          // Si el resultado indica que se añadió o actualizó una planta
          if (result != null && result.created) {
            debugPrint('Se creo una planta');
            setState(() {
              _plantListKey = UniqueKey();
            });

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('¡Planta agregada con éxito!')),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(5),
        ),
        child: Text('+', style: TextStyle(fontSize: 35)),
      ),
      /*persistentFooterButtons: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LogScreen()),
            );
          },
          child: Text('Logs'),
        ),
      ],*/
      body: PlantListScreen(key: _plantListKey),
    );
  }
}

//WORKMANAGER TEST
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case "task-schedule-reminder":
        try {
          List<Reminder> list =
              await DatabaseHelper().getActiveAndPastDueReminders();
          DatabaseHelper().insertLog(
            'Numbers of Reminders activeAndPast: ${list.length}',
          );

          for (var reminder in list) {
            reminder.setNewNextDue();
            //DateTime newNextDue = reminder.nextDue.add(Duration(minutes: 16));
            DatabaseHelper().updateReminderNextDue(reminder, reminder.nextDue);
            Reminder.scheduleNotification(reminder);
          }
        } catch (e) {
          DatabaseHelper().insertLog(
            'Error ejecutando tarea: $e',
            level: LevelLog.error.normalName,
          );
          return Future.error(false);
        }
        break;
      default:
        // Handle unknown task types
        break;
    }
    return Future.value(true);
  });
}
