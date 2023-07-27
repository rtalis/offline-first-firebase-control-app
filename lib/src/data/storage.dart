import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:it_control/models/event.dart';
import 'package:it_control/models/input.dart';
import 'package:it_control/models/local.dart';
import 'package:it_control/models/object.dart';
import 'package:it_control/models/person.dart';
import 'package:path_provider/path_provider.dart';

class FirebaseStorage {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late CollectionReference<Event> _eventCollection;
  late CollectionReference<Local> _localCollection;
  late CollectionReference<ObjectEv> _objectCollection;
  late CollectionReference<Person> _personCollection;
  late CollectionReference<Input> _inputCollection;
  late final DocumentReference<Map<String, dynamic>> _settingsServer;
  late final File _settingsDeviceFile;
  late Map<String, dynamic> _settingsDeviceData;
  late DocumentSnapshot<Map<String, dynamic>> _settingsServerData;
  bool _expiredCache = false;

  // Constants
  static const int cacheExpireDays = 3;

  // Data type strings
  static const String eventDataType = 'event';
  static const String inputDataType = 'input';
  static const String localDataType = 'local';
  static const String objectsDataType = 'objects';
  static const String peopleDataType = 'pessoas';

  // Initialize cache data for each data type
  Map<String, dynamic> _initializeCacheData() {
    final timestampjson =
        timestampToMap(Timestamp.fromDate(DateTime.parse("1970-01-01")));
    return {
      eventDataType: {'lastUpdateCache': timestampjson},
      inputDataType: {'lastUpdateCache': timestampjson},
      localDataType: {'lastUpdateCache': timestampjson},
      objectsDataType: {'lastUpdateCache': timestampjson},
      peopleDataType: {'lastUpdateCache': timestampjson},
      'expire': timestampjson,
    };
  }

  Future<Map<String, dynamic>> _getDeviceSettings() async {
    final jsonData = await _settingsDeviceFile.readAsString();
    _settingsDeviceData = Map<String, dynamic>.from(jsonDecode(jsonData));
    DateTime datePlus3Days = mapToTimestamp(_settingsDeviceData['expire'])
        .toDate()
        .add(const Duration(days: cacheExpireDays));
    DateTime today = DateTime.now();
    if (!_expiredCache) _expiredCache = datePlus3Days.isBefore(today);
    //if cache is older than cacheExpireDays, it will update all cache in device
    if (_expiredCache) {
      _settingsDeviceData['expire'] =
          timestampToMap(Timestamp.fromDate(DateTime.now()));
      await _settingsDeviceFile.writeAsString(jsonEncode(_settingsDeviceData));
    }
    return _settingsDeviceData;
  }

  Future<void> _initializeCacheDocument() async {
    //create the server json files if they don't exist
    final cacheDocumentSnapshot = await _settingsServer.get();
    if (!cacheDocumentSnapshot.exists) {
      await _settingsServer.set({
        eventDataType: {'lastUpdateServer': DateTime.now()},
        inputDataType: {'lastUpdateServer': DateTime.now()},
        localDataType: {'lastUpdateServer': DateTime.now()},
        objectsDataType: {'lastUpdateServer': DateTime.now()},
        peopleDataType: {'lastUpdateServer': DateTime.now()},
      });
    }
    //create the local file if they don't exist
    if (!await fileIsNotEmpty(_settingsDeviceFile)) {
      _settingsDeviceData = _initializeCacheData();
      await _settingsDeviceFile.writeAsString(jsonEncode(_settingsDeviceData));
    }
  }

  Future<List<T>> _loadData<T>(
    CollectionReference<T> collectionRef,
    String cacheKey,
  ) async {
    bool shouldUpdateCache = mapToTimestamp(
                _settingsDeviceData[cacheKey]['lastUpdateCache'])
            .toDate()
            .isBefore(
                _settingsServerData[cacheKey]['lastUpdateServer'].toDate()) ||
        _expiredCache;

    //it will receive data from the server if the cache is not up to date or if the cache is expired
    Source source = shouldUpdateCache ? Source.server : Source.cache;

    var snapshot = await collectionRef.get(GetOptions(source: source));
    var dataList =
        snapshot.docs.map((docSnapshot) => docSnapshot.data()).toList();
    if (shouldUpdateCache) {
      _settingsDeviceData[cacheKey] = {
        'lastUpdateCache': timestampToMap(Timestamp.fromDate(DateTime.now()))
      };
      _settingsDeviceFile.writeAsString(jsonEncode(_settingsDeviceData));
    }

    return dataList;
  }

  CollectionReference<Event> _eventCollectionReference() {
    return _db.collection(eventDataType).withConverter<Event>(
          fromFirestore: Event.fromFirestore,
          toFirestore: (Event input, _) => input.toFirestore(),
        );
  }

  CollectionReference<Input> _inputCollectionReference() {
    return _db.collection(inputDataType).withConverter<Input>(
          fromFirestore: Input.fromFirestore,
          toFirestore: (Input input, _) => input.toFirestore(),
        );
  }

  CollectionReference<Local> _localCollectionReference() {
    return _db.collection(localDataType).withConverter<Local>(
          fromFirestore: Local.fromFirestore,
          toFirestore: (Local input, _) => input.toFirestore(),
        );
  }

  CollectionReference<ObjectEv> _objectCollectionReference() {
    return _db.collection(objectsDataType).withConverter<ObjectEv>(
          fromFirestore: ObjectEv.fromFirestore,
          toFirestore: (ObjectEv input, _) => input.toFirestore(),
        );
  }

  CollectionReference<Person> _personCollectionReference() {
    return _db.collection(peopleDataType).withConverter<Person>(
          fromFirestore: Person.fromFirestore,
          toFirestore: (Person input, _) => input.toFirestore(),
        );
  }

  Future<List<Event>> loadEvents() async {
    _eventCollection = _eventCollectionReference();
    return _loadData<Event>(_eventCollection, eventDataType);
  }

  Future<List<Input>> loadInputs() async {
    _inputCollection = _inputCollectionReference();
    return _loadData<Input>(_inputCollection, inputDataType);
  }

  Future<List<Local>> loadLocals() async {
    _localCollection = _localCollectionReference();
    return _loadData<Local>(_localCollection, localDataType);
  }

  Future<List<ObjectEv>> loadObjects() async {
    _objectCollection = _objectCollectionReference();
    return _loadData<ObjectEv>(_objectCollection, objectsDataType);
  }

  Future<List<Person>> loadPeople() async {
    _personCollection = _personCollectionReference();
    return _loadData<Person>(_personCollection, peopleDataType);
  }

  Future<void> insertEvent(Event event) async {
    _eventCollection = _eventCollectionReference();
    await _eventCollection.doc(event.id).set(event);
    _settingsServer.set({
      eventDataType: {
        'lastUpdateServer': Timestamp.fromDate(DateTime.now()),
      }
    }, SetOptions(merge: true));
  }

  Future<void> insertInput(Input input) async {
    _inputCollection = _inputCollectionReference();
    await _inputCollection.doc(input.id).set(input);
    _settingsServer.set({
      inputDataType: {
        'lastUpdateServer': Timestamp.fromDate(DateTime.now()),
      }
    }, SetOptions(merge: true));
  }

  Future<void> insertLocal(Local local) async {
    _localCollection = _localCollectionReference();
    await _localCollection.doc(local.id).set(local);

    _settingsServer.set({
      localDataType: {
        'lastUpdateServer': Timestamp.fromDate(DateTime.now()),
      }
    }, SetOptions(merge: true));
  }

  Future<void> insertObject(ObjectEv objectEv) async {
    _objectCollection = _objectCollectionReference();
    await _objectCollection.doc(objectEv.id).set(objectEv);

    _settingsServer.set({
      objectsDataType: {
        'lastUpdateServer': Timestamp.fromDate(DateTime.now()),
      }
    }, SetOptions(merge: true));
  }

  Future<void> insertPerson(Person person) async {
    _personCollection = _personCollectionReference();
    await _personCollection.doc(person.id).set(person);

    _settingsServer.set({
      peopleDataType: {
        'lastUpdateServer': Timestamp.fromDate(DateTime.now()),
      }
    }, SetOptions(merge: true));
  }

  Future<String> initSettingsDoc() async {
    _settingsServer =
        FirebaseFirestore.instance.collection('settings').doc('updatedServer');
    final directory = await getApplicationDocumentsDirectory();
    _settingsDeviceFile = File('${directory.path}/settings_device2.json');
    _settingsServerData = await _settingsServer.get();
    await _initializeCacheDocument();
    await _getDeviceSettings();
    return "All set";
  }

  Future<bool> fileIsNotEmpty(File file) async {
    try {
      if (await file.exists()) {
        final content = await file.readAsString();
        return content.isNotEmpty;
      }
      return false;
    } catch (e) {
      //debugPrint('Error while checking JSON file: $e');
      return false;
    }
  }

  Map<String, dynamic> timestampToMap(Timestamp timestamp) {
    return {
      '_seconds': timestamp.seconds,
      '_nanoseconds': timestamp.nanoseconds
    };
  }

  Timestamp mapToTimestamp(Map<String, dynamic> json) {
    return Timestamp(json['_seconds'] as int, json['_nanoseconds'] as int);
  }
}
