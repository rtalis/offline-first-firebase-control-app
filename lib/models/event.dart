import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:it_control/utils/string_utils.dart';

class Event {
  String? id;
  Timestamp? dateTime;
  String? descriptionEvent;
  String? inputEvent;
  String? localEvent;
  String? objectEvent;
  String? personEvent;
  String? typeEvent;
  int? dateSinceEpoch;

  Event({
    this.id,
    this.dateTime,
    this.descriptionEvent,
    this.inputEvent,
    this.localEvent,
    this.objectEvent,
    this.personEvent,
    this.typeEvent,
    this.dateSinceEpoch,
  });

  factory Event.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return Event(
      id: snapshot.id,
      dateTime: data['dateTime'],
      descriptionEvent: capitalize(data['descriptionEvent']),
      inputEvent: data['inputEvent'],
      localEvent: data['localEvent'],
      objectEvent: data['objectEvent'],
      personEvent: data['personEvent'],
      typeEvent: data['typeEvent'],
      dateSinceEpoch: data['dateSinceEpoch'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) 'id': id,
      if (dateTime != null) 'dateTime': dateTime,
      if (descriptionEvent != null)
        'descriptionEvent': capitalize(descriptionEvent!),
      if (inputEvent != null) 'inputEvent': inputEvent,
      if (localEvent != null) 'localEvent': localEvent,
      if (objectEvent != null) 'objectEvent': objectEvent,
      if (personEvent != null) 'personEvent': personEvent,
      if (typeEvent != null) 'typeEvent': typeEvent,
      if (dateSinceEpoch != null) 'dateSinceEpoch': dateSinceEpoch,
    };
  }

  String? get getId => id;
  set setId(String? value) => id = value;

  Timestamp? get getDateTime => dateTime;
  set setDateTime(Timestamp? value) => dateTime = value;

  String? get getDescriptionEvent => descriptionEvent;
  set setDescriptionEvent(String? value) => descriptionEvent = value;

  String? get getInputEvent => inputEvent;
  set setInputEvent(String? value) => inputEvent = value;

  String? get getLocalEvent => localEvent;
  set setLocalEvent(String? value) => localEvent = value;

  String? get getObjectEvent => objectEvent;
  set setObjectEvent(String? value) => objectEvent = value;

  String? get getPersonEvent => personEvent;
  set setPersonEvent(String? value) => personEvent = value;

  String? get getTypeEvent => typeEvent;
  set setTypeEvent(String? value) => typeEvent = value;

  int? get getDateSinceEpoch => dateSinceEpoch;
  set setDateSinceEpoch(int? value) => dateSinceEpoch = value;
}
