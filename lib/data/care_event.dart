import 'package:myapp/data/plant.dart';

class CareEvent {
  int? id;
  Plant? plant;
  DateTime date;
  TypeCareEvent type;
  String? notes;

  CareEvent({required this.date, required this.type, this.notes, this.plant});

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'plantId': plant?.id,
      'date': date.toIso8601String(),
      'type': type,
      'notes': notes,
    };
  }

  static CareEvent fromMap(Map<String, dynamic> map) {
    CareEvent careEvent = CareEvent(
      date: DateTime.parse(map['date'] as String),
      type: map['type'] as TypeCareEvent,
      notes: map['notes'] as String,
      plant: map['plant'] as Plant?,
    );
    careEvent.id = map['id'] as int?;
    return careEvent;
  }

  @override
  String toString() {
    return 'CareEvent{plant: ${plant?.id}, date: $date, type: $type, notes: $notes}';
  }
}

enum TypeCareEvent {
  riego(normalName: 'Riego'),
  fertilizante(normalName: 'Fertilizante'),
  poda(normalName: 'Poda'),
  cambioAbono(normalName: 'Cambio abono');

  final String normalName;
  const TypeCareEvent({required this.normalName});
}
