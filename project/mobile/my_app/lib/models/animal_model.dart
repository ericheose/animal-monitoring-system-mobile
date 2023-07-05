import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/semantics.dart';

class AnimalData {
  const AnimalData({
    required this.id,
    required this.admitted,
    required this.animalAge,
    required this.animalChat,
    required this.animalName,
    required this.animalOwner,
    required this.animalprofilePicture,
    required this.animalSpecies,
    required this.animalStatus,
    required this.animalVet,
  });

  final String id;
  final String admitted;
  final Int animalAge;
  final String animalChat;
  final String animalName;
  final String animalOwner;
  final String animalprofilePicture;
  final String animalSpecies;
  final String animalStatus;
  final String animalVet;

  factory AnimalData.fromSnapshot(DocumentSnapshot document) {
    final data = document.data()!;
    return AnimalData(
      id: document.id,
      admitted: document["admitted"],
      animalAge: document["age"],
      animalChat: document["chat"],
      animalName: document["name"],
      animalOwner: document["owner"],
      animalprofilePicture: document["profilePicture"],
      animalSpecies: document["species"],
      animalStatus: document["status"],
      animalVet: document["vet"],
    );
  }
}
