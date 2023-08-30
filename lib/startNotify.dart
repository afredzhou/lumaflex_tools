import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

Future<List<int>?> startNotify(BluetoothDevice device, String serviceUUID, String characteristicUUID) async {
  final resultList = <int>[];
  List<BluetoothService> services = await device.discoverServices();

  for (BluetoothService service in services) {
    if (service.uuid.toString().toLowerCase() == serviceUUID) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid.toString().toLowerCase() == characteristicUUID) {
          await characteristic.setNotifyValue(true);

          // 创建一个 Completer 用于等待异步事件的完成
          final Completer<List<int>?> completer = Completer();

          // 监听事件流
          StreamSubscription<List<int>> subscription;
          subscription = characteristic.onValueReceived.listen((value) {
            resultList.addAll(value); // 处理新值

            // 检查是否已准备好返回结果
            if (!completer.isCompleted) {
              completer.complete(resultList);
            }
          });

          // 这里可以考虑增加超时逻辑，确保可以及时结束等待

          // 使用 await 等待流结束或超时
          await completer.future;

          // 取消监听事件流
          subscription.cancel();

          return resultList;
        }
      }
    }
  }

  return null;
}
