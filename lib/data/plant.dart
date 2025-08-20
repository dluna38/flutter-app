import 'dart:ffi';

import 'package:myapp/data/reminder.dart';

import 'care_event.dart';

class Plant {
  int? id;
  String name;
  String? species;
  String? location;
  String? notes;
  String? imagePath;
  DateTime? acquisitionDate;
  List<CareEvent> careEvents;
  List<Reminder> reminders;

  Plant({
    this.id,
    required this.name,
    required this.species,
    required this.location,
    this.notes,
    this.imagePath,
    this.acquisitionDate
  }) : careEvents = [],reminders=[];

  Map<String, Object?> toMap([bool withEvents = false]) {
    var map = {
      'id': id,
      'name': name,
      'species': species,
      'location': location,
      'notes': notes,
      'imagePath': imagePath,
      'acquisitionDate':acquisitionDate?.millisecondsSinceEpoch
    };
    if(withEvents){
      map['careEvents'] = careEvents.map((e) => e.toMap()).toList();
    }
    return map;
  }

  static Plant fromMap(Map<String, dynamic> map) {
    Plant plant = Plant(
      name: map['name'] as String,
      species: map['species'] as String,
      location: map['location'] as String,
      notes: map['notes'] as String,
      imagePath: map['imagePath'] as String?,
    );
    if(map['acquisitionDate'] != null){
      plant.acquisitionDate = DateTime.fromMillisecondsSinceEpoch(map['acquisitionDate']);
    }
    plant.id = map['id'] as int?;
    if(map['careEvents'] != null){
      plant.careEvents = (map['careEvents'] as List).map((e) => CareEvent.fromMap(e)).toList();
    }
    return plant;
  }

  @override
  String toString() {
    return 'Plant{id: $id, name: $name, species: $species, location: $location, notes: $notes, imagePath: $imagePath}';
  }
}