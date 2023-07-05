import 'package:flutter/material.dart';
import 'package:my_app/pages/weight-history-page.dart';
import 'package:provider/provider.dart';

import '../database_service.dart';

class AnimalProfilePage extends StatefulWidget {
  final String animalId;

  const AnimalProfilePage({Key? key, required this.animalId}) : super(key: key);

  @override
  _AnimalProfilePageState createState() => _AnimalProfilePageState();
}

class _AnimalProfilePageState extends State<AnimalProfilePage> {
  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: dbService.getAnimal(widget.animalId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData) {
          return const Text("No data");
        }

        var animalData = snapshot.data!;
        var name = animalData['name'] ?? 'No Name';
        var owner = animalData['owner'] ?? 'No Owner';
        var age = animalData['age'] ?? '0';
        var species = animalData['species'] ?? 'No Species';
        var status = animalData['status'] ?? 'No Status';
        var admitted = animalData['admitted'] ?? false;
        var profilePicture = animalData ['profilePicture'] ?? 'No Picture';
        var uid = widget.animalId;
        var vetId = animalData['vet'];

        return Scaffold(
          appBar: AppBar(
            title: const Text("Pet Directory"),
            leading: const BackButton(),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<String>(
                    future: dbService.getAnimalPicture(profilePicture),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (!snapshot.hasData) {
                        return const Text("No picture");
                      }

                      return Center(
                        child: Image.network(
                          snapshot.data!,
                          width: 300,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                  Center(
                      child: Text(name,
                          style: const TextStyle(
                            color: Color(0xFF3A5C75),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ))),
                  Center(
                      child: Text(species,
                          style: const TextStyle(
                            color: Color(0xFF858F97),
                            fontSize: 20,
                          ))),
                  const Divider(),
                  Center(
                      child: Text('ID: $uid',
                          style: const TextStyle(
                            color: Color(0xFF3A5C75),
                            fontSize: 18,
                          ))),
                  Center(
                      child: Text('Age: $age',
                          style: const TextStyle(
                            color: Color(0xFF3A5C75),
                            fontSize: 18,
                          ))),
                  Center(
                      child: Text('Owner: $owner',
                          style: const TextStyle(
                            color: Color(0xFF3A5C75),
                            fontSize: 18,
                          ))),
                  const Divider(),
                  const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text('Vet in charge: ',
                          style: TextStyle(
                            color: Color(0xFF3A5C75),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ))),
                  FutureBuilder<String>(
                    future: dbService.getUserName(vetId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (!snapshot.hasData) {
                        return const Text("No Vet");
                      }

                      var vetName = snapshot.data!;
                      return Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFF1378C6),
                            ),
                            child: Text(
                              vetName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ));
                    },
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text('Status: ',
                        style: TextStyle(
                          color: Color(0xFF3A5C75),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
                  ),

                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                status == 'health' ? Colors.green : Colors.red,
                          ),
                          child: Text(
                            status,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                admitted ? Colors.green : Colors.red,
                          ),
                          child: const Text(
                            'Admitted',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<double>(
                    future: dbService.getLatestWeight(uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (!snapshot.hasData) {
                        return const Text("No Weight Data");
                      }

                      var weight = snapshot.data!;
                      return Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            'Latest Weight: $weight kg',
                            style: const TextStyle(
                              color: Color(0xFF3A5C75),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ));
                    },
                  ),
                  const SizedBox(height: 10),
                  Center(
                      child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              WeightHistoryPage(animalId: uid),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFF1378C6),
                    ),
                    child: const Text(
                      'View Weight History',
                      style: TextStyle(color: Colors.white),
                    ),
                  )), // other widgets ...
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
