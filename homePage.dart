import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import 'package:crud_firebase/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void openNoteBox(
      {String? id, String? currentTitle, String? currentDescription}) {
    if (id != null) {
      titleController.text = currentTitle ?? '';
      descriptionController.text = currentDescription ?? '';
    }

    showDialog(context: context, builder: (context) => AlertDialog(
      backgroundColor: Colors.deepPurple[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: descriptionController,
          )
        ],
      ),
      actions: [
        ElevatedButton(onPressed: (){
          if (id == null){
            firestoreService.adicionarNota(titleController.text, descriptionController.text);
          }else{
            firestoreService.updateNota(titleController.text, descriptionController.text, id);
          }
          titleController.clear();
          descriptionController.clear();
          Navigator.pop(context);
        }, child: const Text('Salvar'))
      ],
    ));
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Notas'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openNoteBox(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty){
            List<DocumentSnapshot> lista_notas = snapshot.data!.docs;
            return ListView.builder(
              itemCount: lista_notas.length,
              itemBuilder: (context,index){
                DocumentSnapshot nota = lista_notas[index];
                String id = nota.id;
                Map<String, dynamic> nota_data = nota.data() as Map<String, dynamic>;
                String titulo = nota_data['titulo'];
                String descricao = nota_data['descricao'];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: ListTile(
                      title: Text(titulo),
                      subtitle: Text(descricao),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => openNoteBox(id: id, currentTitle: titulo, currentDescription: descricao),
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () => firestoreService.deleteNota(id),
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      )
                    ),
                  ),
                );
              },
            );
          }else if(snapshot.hasError){
            return Center(
              child: Text('Erro: ${snapshot.error}'),
            );
          } else{
            return const Center(
              child: Text('Nenhuma nota encontrada'),
            );
          }
        },
      ),
    );
  }
}