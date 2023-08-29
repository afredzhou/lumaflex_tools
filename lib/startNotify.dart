import 'package:flutter_blue_plus/flutter_blue_plus.dart';

Future<List<List<int>>?> startNotify(BluetoothDevice device, String serviceUUID, String characteristicUUID) async {
  List<BluetoothService> services = await device.discoverServices();
  if (services.isNotEmpty) { // 修改了 if 条件，从 device 变为 services
    List<BluetoothService> services = await device.discoverServices();

    for (BluetoothService service in services) { // 使用 for 循环替代 forEach
      if (service.uuid.toString().toLowerCase() == serviceUUID) {
        for (BluetoothCharacteristic characteristic in service.characteristics) { // 使用 for 循环替代 forEach
          if (characteristic.uuid.toString().toLowerCase() == characteristicUUID) {
            characteristic.setNotifyValue(true);
            return await characteristic.value.toList(); // 返回接收到的数据
          }
        }
      }
    }
  }
  return null; // 如果没有找到匹配的服务和特征，返回 null
}
