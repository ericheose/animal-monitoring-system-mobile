import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_app/database_service.dart';
import 'package:my_app/models/animal_model.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'animal-profile-page.dart';

class PetDirectoryPage extends StatefulWidget {
  @override
  _PetDirectoryPageState createState() => _PetDirectoryPageState();
  const PetDirectoryPage({Key? key}) : super(key: key);
}

//This controller will store the value of the serach bar
final TextEditingController _searchController = TextEditingController();

Widget _searchBar() {
  return Container(
    // Add padding around the search bar
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    // Use a Material design search bar
    child: TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search...',
        // Add a clear button to the search bar
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          color: const Color(0xff1976d2),
          onPressed: () => _searchController.clear(),
        ),
        // Add a search icon or button to the search bar
        prefixIcon: IconButton(
          icon: const Icon(Icons.search),
          color: const Color(0xff1976d2),
          onPressed: () {
            // Perform the search here
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    ),
  );
}

Widget _inkWellPush(BuildContext context) {
  return SizedBox(
      height: 20,
      width: 20,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AnimalProfilePage(
                animalId: 'test-animal',
              ),
            ),
          );
        },
      ));
}

Widget _animalDirText() {
  return const Text(
    "Animal Directory",
    style: TextStyle(
      color: Color(0xff3a5c75),
      fontWeight: FontWeight.bold,
      fontSize: 23,
    ),
  );
}

Widget _listOfAnimal(DatabaseService dbService) {
  return Text('error occurred');
}

class _PetDirectoryPageState extends State<PetDirectoryPage> {
  ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context);
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
        child: Scaffold(
      backgroundColor: const Color(0xffeaeaea),
      body: SizedBox(
        height: size.height,
        child: Column(
          children: [
            _searchBar(),
            _inkWellPush(context),
            Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _animalDirText(),
                ],
              ),
            ),
            // _listOfAnimal(dbService),
            FutureBuilder(
              future: dbService.getAnimalsByCenter(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                //check if theres data in future
                if (snapshot.hasData) {
                  print(snapshot.data);

                  List<QueryDocumentSnapshot> animals = snapshot.data!.docs;
                  // .map((animalSnap) => animalSnap.data());
                  var banimal = snapshot.data!.docs
                      .map((animalSnap) => animalSnap.data());
                  print(banimal);
                  // return Text('ha');
                  return Expanded(
                    child: ListView.builder(
                      controller: controller,
                      physics: const BouncingScrollPhysics(),
                      itemCount: animals.length,
                      itemBuilder: (context, index) {
                        // Access the individual QueryDocumentSnapshot using index
                        QueryDocumentSnapshot document = animals[index];
                        String animalId = document.id;
                        // print(animalId);
                        // Customize the appearance of each item as needed
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AnimalProfilePage(animalId: animalId),
                              ),
                            );
                          },
                          child: Container(
                              height: 150,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20.0)),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withAlpha(100),
                                        blurRadius: 10.0),
                                  ]),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          document["name"],
                                          style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          document["species"],
                                          style: const TextStyle(
                                              fontSize: 15, color: Colors.grey),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "${document["status"]}",
                                          style: const TextStyle(
                                              fontSize: 22,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              backgroundColor:
                                                  Colors.pinkAccent),
                                        )
                                      ],
                                    ),
                                    FutureBuilder<String>(
                                      future:
                                          dbService.getAnimalPictureDashboard(
                                              document['profilePicture']),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        }

                                        if (!snapshot.hasData) {
                                          return const Text("No picture");
                                        }
                                        // print(snapshot.data);

                                        // return Image.network(
                                        //   snapshot.data!,
                                        // );
                                        return CachedNetworkImage(
                                          imageUrl: snapshot.data as String,
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              )),
                        );
                      },
                    ),
                  );
                  // return a listview / builder
                  // return ListView.builder(
                  //     padding: const EdgeInsets.all(8),
                  //     itemCount: animals.length,
                  //     itemBuilder: (BuildContext context, int index) {
                  //       return Container(
                  //         height: 50,
                  //         child: ,
                  //       );
                  //     }
                  //   );
                } else {
                  //loading
                  return Text('no data');
                }
              },
            ),
          ],
        ),
      ),
    ));
  }
}
