import 'dart:ffi';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'care_event.dart';
import 'plant.dart';
import 'reminder.dart';

class DatabaseHelper {
  final log = Logger('DatabaseHelper');

  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) {}

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'plants_database.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE plants(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          species TEXT,
          location TEXT,
          notes TEXT,
          imagePath TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE care_events(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          plantId INTEGER,
          date TEXT,
          type TEXT,
          notes TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE reminders(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          plantId INTEGER,
          task TEXT,
          frequency TEXT,
          nextDue TEXT
      )
    ''');
  }

  final String _PLANT_TABLE = "plants";

  Future<int> insertPlant(Plant plant) async {
    try {

      Database db = await database;
      int plantId = await db.insert(_PLANT_TABLE, plant.toMap());
      //TODO check reminders
      /*for (var reminder in plant.reminders) {
        await db.insert('reminders', {
          'plantId': plantId,
          'task': reminder.task,
          'frequency': reminder.frequency,
          'nextDue': reminder.nextDue.toIso8601String(),
        });
      }*/

      return plantId;
    } catch (e) {
      log.severe("Error inserting plant: $e");
      return -1;
    }
  }

  Future<int> insertCareEvent(CareEvent careEvent, int plantId) async {
    try {
      Database db = await database;
      return await db.insert('care_events', {
        'plantId': plantId,
        'date': careEvent.date.toIso8601String(),
        'type': careEvent.type,
        'notes': careEvent.notes,
      });
    } catch (e) {
      log.severe("Error inserting care event: $e");
      return -1;
    }
  }

  Future<int> insertReminder(Reminder reminder) async {
    try {
      Database db = await database;
      int id = await db.insert('reminders', {
        'plantId': reminder.plantId,
        'task': reminder.task,
        'frequency': reminder.frequency,
        'nextDue': reminder.nextDue.toIso8601String(),
      });
      await db.update(
        'plants',
        {},
        where: 'id = ?',
        whereArgs: [reminder.plantId],
      );
      checkReminders();
      return id;
    } catch (e) {
      log.info("Error inserting reminder: $e");
      return -1;
    }
  }

  Future<List<Plant>> getPlants() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('plants');
    List<Plant> plants = List.generate(maps.length, (i) {
      return Plant(
        id: maps[i]['id'],
        name: maps[i]['name'],
        species: maps[i]['species'],
        location: maps[i]['location'],
        notes: maps[i]['notes'],
        imagePath: maps[i]['imagePath'],
      );
    });

    /*for (var plant in plants) {
      final List<Map<String, dynamic>> careEventsMap = await db.query(
        'care_events',
        where: 'plantId = ?',
        whereArgs: [plant.id],
      );
      plant.careEvents = List.generate(careEventsMap.length, (i) {
        return CareEvent(
          date: DateTime.parse(careEventsMap[i]['date']),
          type: careEventsMap[i]['type'],
          notes: careEventsMap[i]['notes'],
        );
      });
      final List<Map<String, dynamic>> remindersMap = await db.query(
        'reminders',
        where: 'plantId = ?',
        whereArgs: [plant.id],
      );
      plant.reminders = List.generate(remindersMap.length, (i) {
        return Reminder(
          plantId: remindersMap[i]['plantId'],
          task: remindersMap[i]['task'],
          frequency: remindersMap[i]['frequency'],
          nextDue: DateTime.parse(remindersMap[i]['nextDue']),
        );
      });
    }*/
    //checkReminders(plants);
    return plants;
  }

  Future<void> checkReminders([List<Plant>? plants]) async {
    Database db = await database;
    final List<Map<String, dynamic>> remindersMap = await db.query('reminders');
    List<Reminder> reminders = List.generate(remindersMap.length, (i) {
      return Reminder(
        id: remindersMap[i]['id'],
        plantId: remindersMap[i]['plantId'],
        task: remindersMap[i]['task'],
        frequency: remindersMap[i]['frequency'],
        nextDue: DateTime.parse(remindersMap[i]['nextDue']),
      );
    });
    List<Plant> allPlants = plants ?? await getPlants();
    for (var reminder in reminders) {
      if (reminder.nextDue.isBefore(DateTime.now())) {
        Plant plant = allPlants.firstWhere(
          (element) => element.id == reminder.plantId,
        );
        await _flutterLocalNotificationsPlugin.show(
          reminder.id! as int,
          'Reminder Due',
          '${reminder.task} - ${plant.name}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'channel_id',
              'channel_name',
              importance: Importance.high,
            ),
          ),
        );
      }
    }
  }

  deleteCareEvent(int id) {}

  deleteReminder(int id) {}

  void deletePlant(int id) async{
    Database db = await database;
    int result =  await db.delete(_PLANT_TABLE,where: 'id=?',whereArgs: [id]);
    //return result
  }
}
