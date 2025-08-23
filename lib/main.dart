import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:myapp/data/reminder.dart';
import 'package:myapp/helpers/my_app_style.dart';
import 'package:myapp/helpers/string_helpers.dart';
import 'package:myapp/screens/debug_notis.dart';
import 'package:myapp/screens/logs_list_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:workmanager/workmanager.dart';

import 'data/database_helper.dart';
import 'helpers/notification_helper.dart';
import 'screens/add_plant_screen.dart';
import 'screens/plant_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  NotificationHelper.initNotifications();
  Workmanager().initialize(callbackDispatcher);

  Workmanager().cancelByUniqueName('schedule-reminder');
  Workmanager().registerPeriodicTask(
    'schedule-reminder',
    'task-schedule-reminder',
    frequency: Duration(hours: 24),
    initialDelay: Duration(seconds: 10),
    existingWorkPolicy: ExistingWorkPolicy.replace
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
      title: 'PlantApp',
      theme: MyAppStyle.lightTheme,
      darkTheme: MyAppStyle.darkTheme,
      themeMode: ThemeMode.system,
      routes: {
        '/': (context) => const NavBarMain(),
        '/add_plant': (context) => const AddPlantScreen(),
        '/plant_list': (context) => const PlantListScreen(),
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: <Locale>[
        const Locale('es','US'),
      ],
      locale: Locale('es','US'),
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
        title:  Text("Mis Plantas",style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
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
        child: Text('+'),
      ),
      persistentFooterButtons: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LogScreen()),
            );
          },
          child: Text('Logs'),
        ),
      ],
      body: PlantListScreen(key: _plantListKey,),
    );
  }
}

class NavBarMain extends StatefulWidget {
  const NavBarMain({super.key});

  @override
  State<NavBarMain> createState() => _NavBarMainState();
}

class _NavBarMainState extends State<NavBarMain> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.green,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Plantas',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_sharp),
            label: 'Notificaciones',
          ),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Guias'),
        ],
      ),
      body:
          <Widget>[
            const HomeScreen(),
            PendingNotificationsScreen(),
            GridView.count(
              // Create a grid with 2 columns.
              // If you change the scrollDirection to horizontal,
              // this produces 2 rows.
              childAspectRatio: 2.0,
              crossAxisCount: 2,
              // Generate 100 widgets that display their index in the list.
              children: List.generate(7, (index) {
                return CardPlant1(index: index);
              }),
            ),
          ][currentPageIndex],
    );
  }
}

class CardPlant1 extends StatelessWidget {
  final int index;
  const CardPlant1({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () {
          debugPrint('Card tapped.');
        },
        leading: const CircleAvatar(child: Icon(Icons.eco_rounded)),
        title: Text('Item $index', style: TextTheme.of(context).headlineSmall),
      ),
    );
  }
}

class DummyGridScreen extends StatelessWidget {
  const DummyGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dummy Grid Screen')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: 20, // Número de tarjetas
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 columnas
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.0, // Relación ancho/alto de cada tarjeta
          ),
          itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              color: Colors.blueGrey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Item ${index + 1}',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            );
          },
        ),
      ),
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
          DatabaseHelper().insertLog('Se ejecuta tarea: task-schedule-reminder');
          List<Reminder> list =
                      await DatabaseHelper().getActiveAndPastDueReminders();
          DatabaseHelper().insertLog('Numbers of Reminders activeAndPast: ${list.length}');

          for (var reminder in list) {
                    DateTime newNextDue = reminder.nextDue.add(Duration(days: reminder.frequencyDays));
                    //DateTime newNextDue = reminder.nextDue.add(Duration(minutes: 16));
                    DatabaseHelper().updateReminderNextDue(reminder, newNextDue);
                    reminder.nextDue = newNextDue;
                    Reminder.scheduleNotification(reminder);
                  }
        } catch (e) {
          DatabaseHelper().insertLog('Error ejecutando tarea: $e',level: LevelLog.error.normalName);
          return Future.error(false);
        }
        break;
      default:
        // Handle unknown task types
        break;
    }

    //task
    /*
    // Schedule a one-time task
      Workmanager().registerOneOffTask(
      "sync-task",
      "data_sync",
      initialDelay: Duration(seconds: 10),
      );

      // Schedule a periodic task
      Workmanager().registerPeriodicTask(
      "cleanup-task",
      "cleanup",
      frequency: Duration(hours: 24),
      );
     */

    return Future.value(true);
  });
}
