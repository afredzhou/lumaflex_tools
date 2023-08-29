import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:math';

extension WriteLarge on BluetoothCharacteristic {
  Future<void> writeLarge(List<int> value, int mtu, {int timeout = 15}) async {
    int chunk = mtu-3;
    for (int i = 0; i < value.length; i += chunk) {
      List<int> subvalue = value.sublist(i, max(i + chunk, value.length));
      write(subvalue,  timeout: timeout);
    }
  }
}
