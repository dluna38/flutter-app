import 'package:myapp/data/plant.dart';

class CareEvent {
  int? id;
  Plant? plant;
  DateTime date;
  TypeCareEvent type;
  String? notes;

  CareEvent({required this.date, required this.type, this.notes, this.plant});

  Map<String, Object?> toMap({bool withId=false}) {
    Map<String, Object?> map ={
      'plantId': plant?.id,
      'date': date.millisecondsSinceEpoch,
      'type': type.index,
      'notes': notes,
    };
    if(withId){
      map['id']=id;
    }
    return map;
  }

  static CareEvent fromMap(Map<String, dynamic> map) {
    CareEvent careEvent = CareEvent(
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      type: TypeCareEvent.values[map['type']],
      notes: map['notes'] as String?,
      plant: map['plant'] as Plant?,
    );
    careEvent.id = map['id'] as int?;
    return careEvent;
  }

  static CareEvent createNow(Plant plant,TypeCareEvent typeCareEvent){
    return CareEvent(
        date: DateTime.now(),
        type: typeCareEvent,
        plant: plant
    );
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
