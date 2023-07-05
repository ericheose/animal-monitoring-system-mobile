import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database_service.dart';

class SaveRecordPage extends StatefulWidget {
  final double weight;

  SaveRecordPage({required this.weight});

  @override
  _SaveRecordPageState createState() => _SaveRecordPageState();
}

class _SaveRecordPageState extends State<SaveRecordPage> {
  String? selectedAnimalId;
  Map<String, String>? animals;

  @override
  void initState() {
    super.initState();
    loadAnimals();
  }

  Future<void> loadAnimals() async {
    final dbService = Provider.of<DatabaseService>(context, listen: false);
    var result = await dbService.getAnimalsByCenter();
    setState(() {
      animals = result.docs.asMap().map((_, doc) => MapEntry(doc['name'], doc.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Save Record"),
      ),
      body: animals == null
          ? CircularProgressIndicator()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Weight: ${widget.weight}',
                    style: TextStyle(
                      color: Color(0xFF3A5C75),
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return const Iterable<String>.empty();
                      }
                      return animals!.keys.where((String option) {
                        return option
                            .toLowerCase()
                            .startsWith(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      selectedAnimalId = animals![selection];
                    },
                    fieldViewBuilder: (BuildContext context,
                        TextEditingController fieldTextEditingController,
                        FocusNode fieldFocusNode,
                        VoidCallback onFieldSubmitted) {
                      return TextFormField(
                        controller: fieldTextEditingController,
                        focusNode: fieldFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Search Animals',
                          border: OutlineInputBorder(),
                        ),
                        onFieldSubmitted: (String value) {
                          onFieldSubmitted();
                        },
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // Save the weight record under the animal in Firestore.
                      if (selectedAnimalId != null) {
                        await FirebaseFirestore.instance
                            .collection('animals')
                            .doc(selectedAnimalId)
                            .collection('weights')
                            .add({
                          'timestamp': Timestamp.now(),
                          'weigher': FirebaseFirestore.instance
                              .collection("users")
                              .doc(FirebaseAuth.instance.currentUser!.uid),
                          'weight': widget.weight,
                        });

                        // Then, navigate back to the previous page.
                        Navigator.pop(context);
                      } else {
                        print('No animal selected.');
                      }
                    },
                    child: Text('Save'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
