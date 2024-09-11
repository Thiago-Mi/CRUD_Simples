import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference notes = FirebaseFirestore.instance.collection('notes');

  Future<void> adicionarNota(String titulo, String descricao){
    return notes.add({
      'titulo': titulo,
      'descricao': descricao,
      'timestamp': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getNotas(){
    return notes.orderBy('timestamp',descending: true).snapshots();
  }

  Future<void> updateNota(String titulo, String descricao, String id){
    return notes.doc(id).update({
      'titulo': titulo,
      'descricao': descricao,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> deleteNota(String id){
    return notes.doc(id).delete();
  }

}