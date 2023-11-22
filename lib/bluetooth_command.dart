
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lumaflex_tools/view/custom_app_bar.dart';
import 'package:lumaflex_tools/write_value.dart';
import 'bytes_to_hex_string.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:lumaflex_tools/startNotify.dart';
import 'package:get/get.dart';
final RxString deviceName = Get.find();
final RxBool kDebugMode = Get.find();
class BluetoothCommand extends StatefulWidget {
  final BluetoothDevice device;// 添加一个名为 Device 的参数
  const BluetoothCommand({Key? key, required this.device}) : super(key: key);
  @override
  BluetoothCommandState createState() => BluetoothCommandState();
}

class BluetoothCommandState extends State<BluetoothCommand> {
  final List<String> buttonLabels =[
    "区域1",  "开始", "结束", "暂停", '关机', '平衡调光', '弹力调光', '集中调光', '冥想调光',];
  static const commandList = [[0x11], [0x02], [0x04],  [0x03],   [0x17],   [0x33],  [0x49],   [0x81],    [0x97],  ];
  var data = "".obs;
  static const serviceUUID = '0000fff0-0000-1000-8000-00805f9b34fb';
  static const characteristicUUID = '0000fffb-0000-1000-8000-00805f9b34fb';
  static const readCharacteristicUUID = '0000fffa-0000-1000-8000-00805f9b34fb';
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () async {
      final services = await widget.device.discoverServices();
      for (BluetoothService service in services) {
        if (service.uuid.toString() == serviceUUID) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == readCharacteristicUUID) {
              // 使用await获取Stream
              final Stream<List<int>?> valuesStream = await startNotify(
                  widget.device, serviceUUID, readCharacteristicUUID);
              // 监听Stream的值
              valuesStream.listen((bytes) {
                // 将字节转换为hex string
                String hexString = bytesToHexString(bytes);
                // 更新UI
                data.value = hexString;
              });
              // await    writeValue(widget.device, serviceUUID, characteristicUUID, data);
            }
          }
        }
      }

    });

  }
  // List<int> hexList = [0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff];
  void onCommandSent (List<int> data) async{
    final services = await widget.device.discoverServices();
    for (BluetoothService service in services) {
      if (service.uuid.toString() == serviceUUID) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == characteristicUUID) {
            await    writeValue(widget.device, serviceUUID, characteristicUUID, data);
          }
        }
      }
    }

  }
  // void turnOff(device) async {
  //   try {
  //     List<BluetoothService> services = await widget.device.discoverServices();
  //      const off_commad_hex_String = "0000000000ff00ffffffffffffffffffff";
  //      // final mtu = 23;
  //     // Request MTU size
  //     for (BluetoothService service in services) {
  //       if (service.uuid.toString() == serviceUUID) {
  //         for (BluetoothCharacteristic characteristic in service.characteristics) {
  //           if (characteristic.uuid.toString() == characteristicUUID) {
  //             var hexList= convertHexStringToList(off_commad_hex_String);
  //
  //
  //             kDebugMode.value ? print(hexList) : null;
  //
  //
  //             // await characteristic.writeLarge(hexList, mtu);
  //             await characteristic.write(hexList); // Write data using WriteLarge extension
  //           }
  //         }
  //       }
  //     }
  //   } catch (e) {
  //
  //     kDebugMode.value ? print('Error : $e'):null;
  //
  //   }
  // }

  void switchButton(List<int> intList) async {
    try {
      List<BluetoothService> services = await widget.device.discoverServices();
      // const off_commad_hex_String = "0000000000ff00ffffffffffffffffffff";
      final red_light_command =  intList;
      for (BluetoothService service in services) {
        if (service.uuid.toString() == serviceUUID) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == characteristicUUID) {
              // var hexList= convertHexStringToList(off_commad_hex_String);
              print(red_light_command  );
              // await characteristic.writeLarge(hexList, mtu);
              await characteristic.write(red_light_command); // Write data using WriteLarge extension
            }
          }
        }
      }
    } catch (e) {
      print('Error : $e');
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title:deviceName.value,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Image.asset(
            //   'assets/images/lumaflex.png',
            //   width: 600,
            //   fit: BoxFit.fitWidth,
            // ),
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() => Text(
                    'Data from ${deviceName.value}: ${data.value}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.red,
                    ),
                  ))  ,
                  Text('Device: ${widget.device.localName}',
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.black,
                    // 添加其他样式属性
                  ),
                ),
                  Text('Remote ID: ${widget.device.remoteId}',style: const TextStyle(
                    fontSize: 22,
                    color: Colors.black,
                    // 添加其他样式属性
                  ),),
                  Text('Device Type: ${widget.device.type}',
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                      // 添加其他样式属性
                    ),),]
            ),
            SizedBox(
              width: 500,
              height: 800,
              child: ListView.builder(
                itemCount: buttonLabels.length,
                itemBuilder: (BuildContext context, int index) {
                  final label = buttonLabels[index];
                  final command= Uint8List.fromList(commandList[index]);
                  return ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red), // 设置背景颜色为红色
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // 设置圆角半径
                        ),
                      ),
                    ),
                    onPressed: () => onCommandSent(command),
                    child: Text(label),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
