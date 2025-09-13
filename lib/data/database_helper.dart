
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:myapp/helpers/io_helpers.dart';
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
          imagePath TEXT,
          acquisitionDate INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE care_events(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          plantId INTEGER,
          date INTEGER,
          type INTEGER,
          notes TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE reminders(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          plantId INTEGER,
          task TEXT,
          frequency INTEGER,
          nextDue INTEGER,
          active INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE logs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      timestamp INTEGER,
      level TEXT,
      message TEXT
    );
    ''');
  }

  static const String _PLANT_TABLE = "plants";
  static const String _REMINDERS_TABLE = 'reminders';
  static const String _CARE_EVENTS_TABLE = 'care_events';

  //PLANTS
  Future<int> insertPlant(Plant plant) async {
    try {

      if(plant.imagePath!= null){
        plant.imagePath= (await IOHelpers.saveImageToLocalStorage(plant.imagePath!,imageName: '${plant.name}_${plant.species}')).path;
      }
      Database db = await database;
      int plantId = await db.insert(_PLANT_TABLE, plant.toMap());

      return plantId;
    } catch (e) {
      log.severe("Error inserting plant: $e");
      return -1;
    }
  }
  Future<int> updatePlant(Plant newPlant,Plant oldPlant) async {
    try {
      Map<String, Object?> map = {};
      if(newPlant.name != oldPlant.name){
        map['name'] = newPlant.name;
      }
      if(newPlant.species != oldPlant.species){
        map['species'] = newPlant.species;
      }
      if(newPlant.location != oldPlant.location){
        map['location'] = newPlant.location;
      }
      if(newPlant.notes != oldPlant.notes){
        map['notes'] = newPlant.notes;
      }
      if(newPlant.acquisitionDate != oldPlant.acquisitionDate){
        map['acquisitionDate'] = newPlant.acquisitionDate?.millisecondsSinceEpoch;
      }


      if(newPlant.imagePath!= null && newPlant.imagePath != oldPlant.imagePath){
        //delete old image - check if null
        if(oldPlant.imagePath !=null){
          IOHelpers.removeImageFromLocalStorage(oldPlant.imagePath!);
        }
        map['imagePath'] = (await IOHelpers.saveImageToLocalStorage(newPlant.imagePath!,imageName: '${newPlant.name}_${newPlant.species}')).path;
      }
      if(newPlant.imagePath== null && oldPlant.imagePath!=null){
        await IOHelpers.removeImageFromLocalStorage(oldPlant.imagePath!);
        // Establecemos la ruta de la imagen a null en el mapa para la base de datos
        map['imagePath'] = null;
      }

      if (map.isEmpty) {
        return oldPlant.id!; // No hay cambios, devuelve el ID existente
      }


      Database db = await database;
      int plantId = await db.update(_PLANT_TABLE, map,where: 'id=?',whereArgs: [oldPlant.id]);

      return plantId;
    } catch (e) {
      log.severe("Error inserting plant: $e");
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

    return plants;
  }
  Future<Plant?> getPlantById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      _PLANT_TABLE,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Plant.fromMap(maps.first);
    }
    return null;
  }

  void deletePlant(int id) async {
    Database db = await database;
    await db.delete(_PLANT_TABLE, where: 'id=?', whereArgs: [id]);
    //return result
  }

  //CARE EVENTS
  Future<int> insertCareEvent(CareEvent careEvent, int plantId) async {
    try {
      Database db = await database;
      careEvent.plant?.id = plantId;
      return await db.insert('care_events', careEvent.toMap());
    } catch (e) {
      log.severe("Error inserting care event: $e");
      return -1;
    }
  }
  deleteCareEvent(int id) {}

  Future<List<CareEvent>> getCareEvents(int plantId, {Map<String, String> filters = const {}}) async {
    Database db = await database;

    // Cláusulas WHERE y argumentos para construir la consulta
    final List<String> whereClauses = ['plantId = ?'];
    final List<dynamic> whereArgs = [plantId];

    // Extrae y valida los filtros restantes
    final String orderBy = filters['orderBy'] ?? 'date DESC';
    final int? limit = int.tryParse(filters['limit'] ?? '');

    // Filtro por tipo de evento
    if (filters.containsKey('type') && int.tryParse(filters['type']!) != null) {

      whereClauses.add('type = ?');
      whereArgs.add(filters['type']);
    }

    // Filtro por fecha de inicio (si existe)
    if (filters.containsKey('startDate')) {
      final startDate = DateTime.tryParse(filters['startDate']!)?.millisecondsSinceEpoch;
      if (startDate != null) {
        whereClauses.add('date >= ?');
        whereArgs.add(startDate);
      }
    }

    // Filtro por fecha de fin (si existe)
    if (filters.containsKey('endDate')) {
      final endDate = DateTime.tryParse(filters['endDate']!)?.millisecondsSinceEpoch;
      if (endDate != null) {
        whereClauses.add('date <= ?');
        whereArgs.add(endDate);
      }
    }

    final String whereString = whereClauses.join(' AND ');

    final List<Map<String, dynamic>> maps = await db.query(
      _CARE_EVENTS_TABLE,
      where: whereString,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return CareEvent.fromMap(maps[i]);
    });
  }

  Future<int> insertReminder(Reminder reminder) async {
    try {
      Database db = await database;
      int id = await db.insert('reminders', {
        'plantId': reminder.plantId,
        'task': reminder.task,
        'frequency': reminder.frequencyDays,
        'nextDue': reminder.nextDue.millisecondsSinceEpoch,
        'active': reminder.active
      });
      return id;
    } catch (e) {
      log.info("Error inserting reminder: $e");
      return -1;
    }
  }

  Future<int> deleteReminder(int id) async{
    Database db = await database;
    return await db.delete(_REMINDERS_TABLE, where: 'id=?', whereArgs: [id]);
  }
  Future<List<Reminder>> getReminders(int plantId) async{
    Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      _REMINDERS_TABLE,
      where: 'plantId=?',
      whereArgs: [plantId],
      orderBy: 'id DESC',
    );

    return List.generate(maps.length, (i) {
      return Reminder.fromMap(maps[i]);
    });
  }
  Future<List<Reminder>> getActiveAndPastDueReminders() async {
    Database db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final List<Map<String, dynamic>> maps = await db.query(
      'reminders',
      where: 'active = ? AND nextDue <= ?', // Filtrar por `active` y `nextDue`
      whereArgs: [1, now], // 1 para true, y `now` para la fecha
    );

    return List.generate(maps.length, (i) {
      return Reminder.fromMap(maps[i]);
    });
  }

  void updateReminderNextDue(Reminder reminder, DateTime newNextDue) async{
    Database db = await database;
    final int newNextDueMillis = newNextDue.millisecondsSinceEpoch;
    await db.update(
      _REMINDERS_TABLE,
      {'nextDue': newNextDueMillis},
      where: 'id = ?',
      whereArgs: [reminder.id!],
    );
  }

  //LOGS
  Future<void> insertLog(String message, {String level = 'INFO'}) async {
    debugPrint("$level| $message");
    /*final Database db = await database;
    await db.insert(
      'logs',
      {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'level': level,
        'message': message,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );*/
  }

  Future<List<Map<String, dynamic>>> getLogs() async {
    final Database db = await database;
    return await db.query(
      'logs',
      orderBy: 'timestamp DESC', // Ordena por los más recientes primero
    );
  }

}
