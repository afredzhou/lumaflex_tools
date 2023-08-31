import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

Future<Stream<List<int>?>> startNotify(
    BluetoothDevice device, String serviceUUID, String characteristicUUID) async {

  List<BluetoothService> services = await device.discoverServices();

  for (BluetoothService service in services) {
    if (service.uuid.toString().toLowerCase() == serviceUUID) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid.toString().toLowerCase() == characteristicUUID) {

          // 启用notify
          await characteristic.setNotifyValue(true);

          // 监听值变化
          StreamSubscription<List<int>> subscription =
          characteristic.onValueReceived.listen((value) {});

          // 返回Characteristic的值流
          return characteristic.onValueReceived;
        }
      }
    }
  }

  // 没有找到Characteristic,抛出异常
  throw 'Characteristic $characteristicUUID not found';
}

// 使用
// Stream<List<int>> values = await startNotify(device, serviceUUID, characteristicUUID);
