import 'package:cloud_firestore/cloud_firestore.dart';

class Local {
  final String? id;
  final String? name;
  Local({
    this.id,
    this.name,
  });

  factory Local.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Local(
      id: data?['id'],
      name: data?['nome_local'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) "id": id,
      if (name != null) "nome_local": name,
    };
  }
}
