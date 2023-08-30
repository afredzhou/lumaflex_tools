import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
final RxString deviceName = Get.find();
Future<BluetoothDevice> startScan() {
  final completer = Completer<BluetoothDevice>();

  BluetoothDevice unknownDevice = BluetoothDevice(
    remoteId: const DeviceIdentifier('00:00:00:00:00:00'),
    localName: 'unknownDevice',
    type: BluetoothDeviceType.unknown,
  );

  FlutterBluePlus.startScan(timeout: const Duration(seconds: 20));

  StreamSubscription<List<ScanResult>>? scanSubscription;
  scanSubscription = FlutterBluePlus.scanResults.listen((results) {
    BluetoothDevice device = results
        .map((result) => result.device)
        .firstWhere((device) => device.localName == deviceName.value,
        orElse: () => unknownDevice);
    if (!completer.isCompleted && device != unknownDevice) {
      // 完成Completer并返回设备
      completer.complete(device);
      // 取消扫描订阅
      scanSubscription?.cancel();
    }
  });

  return completer.future;
}
