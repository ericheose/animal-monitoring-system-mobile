import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_app/models/animal_model.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseService with ChangeNotifier {
  String? _uid;

  DatabaseService({String? uid}) : _uid = uid;

  String? get uid => _uid;

  set uid(String? uid) {
    _uid = uid;
    notifyListeners();
  }

  // reference for our collections
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference chatCollection =
      FirebaseFirestore.instance.collection("chats");
  final FirebaseStorage storage = FirebaseStorage.instance;
  final CollectionReference animalCollection =
      FirebaseFirestore.instance.collection("animals");
  final CollectionReference centerCollection =
      FirebaseFirestore.instance.collection("centers");

  Stream<QuerySnapshot> getChatMessages(String chatId) {
    return chatCollection
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  Stream<List<DocumentSnapshot>> getUserChats() async* {
    DocumentSnapshot userDoc = await userCollection.doc(uid).get();
    List<DocumentReference> chatRefs = (userDoc['chats'] as List)
        .map((item) => item as DocumentReference)
        .toList(); // this should be a list of DocumentReferences

    List<Stream<DocumentSnapshot>> chatStreams =
        chatRefs.map((ref) => ref.snapshots()).toList();

    // Combine the streams into a single stream that emits a list of DocumentSnapshots whenever any of the chat documents update.
    yield* StreamZip(chatStreams).asBroadcastStream();
  }

  // Create chat
  Future createChat(String user1Id, String user2Id) async {
    DocumentReference user1Ref = userCollection.doc(user1Id);
    DocumentReference user2Ref = userCollection.doc(user2Id);

    DocumentReference chatRef = await chatCollection.add({
      'users': [user1Ref, user2Ref]
    });

    return chatRef.id;
  }

  Future<String> getUserName(DocumentReference userRef) async {
    DocumentSnapshot userDoc = await userRef.get();

    if (userDoc.exists) {
      return userDoc.get('name') as String;
    } else {
      throw Exception('User does not exist');
    }
  }

  Future<DocumentReference> getUserCenter() async {
    DocumentSnapshot userDoc = await userCollection.doc(uid).get();

    if (userDoc.exists) {
      return userDoc.get('center') as DocumentReference;
    } else {
      throw Exception('User does not exist');
    }
  }

  Future<Map<String, dynamic>> getAnimal(String animalId) async {
    DocumentSnapshot animalDoc = await animalCollection.doc(animalId).get();

    if (!animalDoc.exists) {
      throw Exception('No such animal');
    }

    return animalDoc.data() as Map<String, dynamic>;
  }

  Future<List<AnimalData>> getAnimalsCenter(String centerId) async {
    QuerySnapshot snapshot =
        await animalCollection.where('center', isEqualTo: centerId).get();

    print(snapshot);
    List<AnimalData> users = [];
    snapshot.docs.forEach((doc) {
      users.add(AnimalData.fromSnapshot(doc));
    });
    print(users);
    return users;
  }

  Future<QuerySnapshot> getAdmittedAnimals() async {
    return await animalCollection.where('admitted', isEqualTo: true).get();
  }

  Future<String> getAnimalCenter(DocumentReference animalRef) async {
    DocumentSnapshot document = await animalRef.get();

    if (document.exists) {
      return document.get('center') as String;
    } else {
      throw Exception('User does not exist');
    }
  }

  Future<Map<String, String>> getWeighersNames(
      List<QueryDocumentSnapshot> weightDocs) async {
    // Get unique weigher references
    var weigherRefs =
        weightDocs.map((doc) => doc['weigher'] as DocumentReference).toSet();

    // Fetch each weigher's name
    var weighersNames = <String, String>{};
    var count = 0;

    for (var ref in weigherRefs) {
      try {
        var name = await getUserName(ref);
        weighersNames[ref.id] = name;
        count++;
      } catch (e) {
        print('Error fetching user name: $e');
      }
    }
    return weighersNames;
  }

  Future<double> getLatestWeight(String animalId) async {
    var weightDoc = await FirebaseFirestore.instance
        .collection('animals')
        .doc(animalId)
        .collection('weights')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (weightDoc.docs.isNotEmpty) {
      return weightDoc.docs.first.data()['weight'];
    } else {
      throw Exception('No weight data');
    }
  }

  Future<QuerySnapshot> getWeightHistory(String animalId) async {
    return await FirebaseFirestore.instance
        .collection('animals')
        .doc(animalId)
        .collection('weights')
        .orderBy('timestamp', descending: true)
        .get();
  }

  Future<String> getLastMessageContent(DocumentSnapshot chatSnap) async {
    QuerySnapshot messageDocs = await chatSnap.reference
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .get();

    if (messageDocs.docs.isNotEmpty) {
      return messageDocs.docs.first.get('content') as String;
    } else {
      throw Exception('No messages in the chat');
    }
  }

  Future<Timestamp> getLastMessageTimeStamp(DocumentSnapshot chatSnap) async {
    QuerySnapshot messageDocs = await chatSnap.reference
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .get();

    if (messageDocs.docs.isNotEmpty) {
      return messageDocs.docs.first.get('timestamp') as Timestamp;
    } else {
      throw Exception('No messages in the chat');
    }
  }

  Future<String> getUserProfilePicture(String uid) async {
    try {
      String profilePictureURL =
          await storage.ref('users/$uid.jpg').getDownloadURL();
      return profilePictureURL;
    } catch (e) {
      throw Exception('Failed to retrieve profile picture');
    }
  }

  Future<QuerySnapshot> getAnimalsByCenter() async {
    return await animalCollection
        .where('center', isEqualTo: await getUserCenter())
        .get();
  }

  Future<QuerySnapshot> getNotAdmittedAnimals() async {
    return await animalCollection.where('admitted', isEqualTo: false).get();
  }

  Future<String> getAnimalPicture(String uid) async {
    try {
      String profilePictureURL =
          await storage.ref('animals/$uid').getDownloadURL();
      return profilePictureURL;
    } catch (e) {
      throw Exception('Failed to retrieve profile picture');
    }
  }

  Future<String> getAnimalPictureDashboard(String uid) async {
    try {
      String profilePictureURL =
          await storage.ref('animals/$uid').getDownloadURL();
      return profilePictureURL;
    } catch (e) {
      throw Exception('Failed to retrieve profile picture');
    }
  }

  Future<String> getUserUid(DocumentReference userRef) async {
    DocumentSnapshot userDoc = await userRef.get();

    if (userDoc.exists) {
      return userDoc.id; // Assuming the user's UID is the ID of the document.
    } else {
      throw Exception('User does not exist');
    }
  }

  // Send message
  Future sendMessage(String chatId, String messageContent) async {
    DocumentReference userRef = userCollection.doc(uid);
    CollectionReference messages =
        chatCollection.doc(chatId).collection('messages');

    return messages.add({
      'content': messageContent,
      'sender': userRef,
      'timestamp': Timestamp.now(),
    });
  }

  Query getChatMessagesQuery(String chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages');
  }

  Stream<QuerySnapshot> getLatestChatMessagesStream(String chatId, int limit) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }
}
