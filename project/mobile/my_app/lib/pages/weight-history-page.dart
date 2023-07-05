import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../database_service.dart';

class WeightHistoryPage extends StatefulWidget {
  final String animalId;

  const WeightHistoryPage({Key? key, required this.animalId}) : super(key: key);

  @override
  _WeightHistoryPageState createState() => _WeightHistoryPageState();
}

class _WeightHistoryPageState extends State<WeightHistoryPage> {
  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight History'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: dbService.getWeightHistory(widget.animalId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (!snapshot.hasData) {
            return const Text("No data");
          }

          var weightDocs = snapshot.data!.docs;
          // fetch all unique weighers
          return FutureBuilder<Map<String, String>>(
            future: dbService.getWeighersNames(weightDocs),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (!snapshot.hasData) {
                return const Text("Can't fetch weighers' names");
              }

              var weighersNames = snapshot.data!;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Text('Weight (kg)'),
                    ),
                    DataColumn(
                      label: Text('Date'),
                    ),
                    DataColumn(
                      label: Text('Weigher'),
                    ),
                  ],
                  rows: weightDocs.map<DataRow>((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    var weight = data['weight'].toString();

                    var timestamp = data['timestamp'] as Timestamp;
                    var date = DateFormat('yyyy-MM-dd HH:mm')
                        .format(timestamp.toDate());

                    var weigherId = (data['weigher'] as DocumentReference).id;
                    var weigher = weighersNames[weigherId] ?? 'Unknown';

                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(weight)),
                        DataCell(Text(date)),
                        DataCell(Text(weigher)),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
