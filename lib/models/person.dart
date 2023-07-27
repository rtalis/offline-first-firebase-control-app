import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  final String? id;
  final String? role;
  final String? name;
  final String? registration;
  final String? nameID;

  Person({this.id, this.role, this.name, this.registration, this.nameID});

  factory Person.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Person(
      id: data?['id'],
      role: data?['funcao'],
      name: data?['nome_servidor'],
      registration: data?['matricula'],
      nameID: "${data?['nome_servidor']} - ${data?['matricula']}",
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) "id": id,
      if (role != null) "funcao": role!.toUpperCase(),
      if (name != null) "nome_servidor": name!.toUpperCase(),
      if (registration != null) "matricula": registration,
    };
  }
}
