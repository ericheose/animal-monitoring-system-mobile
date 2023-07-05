import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:my_app/models/bluetooth_controller.dart';
import 'package:my_app/pages/save-record-page.dart';

class WeighPetPage extends StatefulWidget {
  @override
  _WeighPetPageState createState() => _WeighPetPageState();
  const WeighPetPage({Key? key}) : super(key: key);
}

class _WeighPetPageState extends State<WeighPetPage> {
  double weight = 0.0;
  double finalWeight = 0.0;

  double parseWeight(List<int> value) {
    return value[0] + value[1] / 100.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<BluetoothController>(
          init: BluetoothController(),
          builder: (controller) {
            return ListView(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.blue,
                  child: const Center(
                      child: Text(
                    "bluetooth Devices",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                    child: ElevatedButton(
                        onPressed: () => controller.scanDevices(),
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                            minimumSize: const Size(350, 55),
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)))),
                        child: const Text(
                          "Scan",
                          style: TextStyle(fontSize: 18),
                        ))),
                const SizedBox(height: 20),
                StreamBuilder<List<ScanResult>>(
                  stream: controller.scanResults,
                  builder: (context, snapshot) {
                    // Check if a device is already connected
                    if (controller.connectedDevice != null) {
                      print('Connected device found');
                      controller.connectedDevice
                          ?.discoverServices()
                          .then((services) {
                        for (var service in services) {
                          for (var characteristic in service.characteristics) {
                            characteristic.setNotifyValue(true).then((value) {
                              if (value) {
                                characteristic.value.listen((event) {
                                  print(event);
                                  List<int> reversedList =
                                      List.from(event.reversed);
                                  ByteBuffer buffer =
                                      Int8List.fromList(reversedList).buffer;
                                  ByteData byteData = ByteData.view(buffer);
                                  setState(() {
                                    weight =  double.parse((byteData.getFloat32(0)).toStringAsFixed(2));
                                  });
                                  print(weight);
                                });
                              }
                            });
                          }
                        }
                      });
                      return Column(
                        children: [
                          Center(
                            child: Text(
                              "Connected to: ${controller.connectedDevice!.name}",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => controller.disconnect(),
                            child: const Text("Disconnect"),
                          ),
                        ],
                      );
                    }

                    // No device is connected, handle the case when scan results are available
                    else if (snapshot.hasData) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final data = snapshot.data![index];
                          if (!data.device.name.contains('SPCA')) {
                            return Container();
                          } else {
                            return Card(
                              elevation: 2,
                              child: ListTile(
                                title: Text(data.device.name),
                                subtitle: Text(data.device.id.id),
                                trailing: Text(data.rssi.toString()),
                                onTap: () => controller.connect(data.device),
                              ),
                            );
                          }
                        },
                      );
                    }

                    // No device is connected, and no scan results are available
                    else {
                      return const Center(child: Text("No devices found"));
                    }
                  },
                ),
                const SizedBox(height: 20),
              
                Center(
                    child: Text("$weight",
                    
                        style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 81,
                            fontWeight: FontWeight.bold))),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Here you should have code that reads the weight data from the device.

                      // Navigate to a new page that only displays the weight value.
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SaveRecordPage(weight: weight),
                        ),
                      );
                    },
                    child: const Text("Capture Weight"),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          }),
    );
  }
}
