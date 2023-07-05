import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class BluetoothController extends GetxController {
  BluetoothDevice? connectedDevice;
  //create
  FlutterBluePlus flutterBluePlus = FlutterBluePlus.instance;

  bool get isConnected => connectedDevice != null;

  Future scanDevices() async {
    print('scan start');

    // starting scan from here. Scan for 10 sec
    flutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    // Delay the stopScan call for 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      //stop scan
      flutterBluePlus.stopScan();
      print('scan ended');
    });
  }

  // scanning completed.

  Stream<List<ScanResult>> get scanResults => flutterBluePlus.scanResults;

  //Connected to the devices
  Future connect(BluetoothDevice device) async {
    try {
      print('Connecting to ${device.name}...');
      await device.connect(autoConnect: true);
      connectedDevice = device; // Remember the connected device
      print('Connected!');
      update(); // Force UI update
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }

  Future disconnect() async {
    if (connectedDevice != null) {
      try {
        print('Disconnecting from ${connectedDevice!.name}...');
        await connectedDevice!.disconnect();
        connectedDevice = null; // Forget the connected device
        print('Disconnected!');
        update(); // Force UI update
      } catch (e) {
        print('Error disconnecting from device: $e');
      }
    }
  }
}
