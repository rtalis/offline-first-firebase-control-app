import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:it_control/utils/string_utils.dart';

class ObjectEv {
  final String? id;
  final String? local;
  final String? name;
  final String? registration;
  final String? type;
  final String? nameRegistration;
  ObjectEv(
      {this.id,
      this.local,
      this.name,
      this.registration,
      this.type,
      this.nameRegistration});

  factory ObjectEv.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return ObjectEv(
        id: data?['id'],
        local: data?['local'],
        name: data?['nm_obj'],
        registration: data?['tombo_obj'].toString(),
        type: data?['tp_obj'],
        nameRegistration:
            "${capitalize(data?['nm_obj'])} - ${data?['tombo_obj']}");
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) "id": id,
      if (local != null) "local": local,
      if (name != null) "nm_obj": name,
      if (registration != null) "tombo_obj": registration,
      if (type != null) "tp_obj": type,
    };
  }
}
