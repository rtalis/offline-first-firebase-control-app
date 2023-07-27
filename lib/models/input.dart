import 'package:cloud_firestore/cloud_firestore.dart';

class Input {
  final String? id;
  final String? name;
  Input({
    this.id,
    this.name,
  });

  factory Input.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Input(
      id: data?['id'],
      name: data?['nome_insumo'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) "id": id,
      if (name != null) "nome_insumo": name,
    };
  }
}
