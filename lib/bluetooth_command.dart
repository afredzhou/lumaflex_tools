
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lumaflex_tools/view/custom_app_bar.dart';
import 'bytesToHexString.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:lumaflex_tools/startNotify.dart';
import 'package:get/get.dart';

class BluetoothCommand extends StatefulWidget {
  final BluetoothDevice device;// 添加一个名为 Device 的参数
  const BluetoothCommand({Key? key, required this.device}) : super(key: key);

  @override
  BluetoothCommandState createState() => BluetoothCommandState();
}

class BluetoothCommandState extends State<BluetoothCommand> {
  var data = "".obs;
  static const serviceUUID = '0000ff00-0000-1000-8000-00805f9b34fb';
  static const characteristicUUID = '0000ff02-0000-1000-8000-00805f9b34fb';
  static const readCharacteristicUUID = '0000ff01-0000-1000-8000-00805f9b34fb';

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () async
    {
      data.value = (await startNotify(
              widget.device,
              serviceUUID,
              readCharacteristicUUID,
            )) as String; });
  }
  // List<int> hexList = [0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff];

  void turnOff(device) async {
    try {
      List<BluetoothService> services = await widget.device.discoverServices();
       const off_commad_hex_String = "0000000000ff00ffffffffffffffffffff";
       // final mtu = 23;
      // Request MTU size
      for (BluetoothService service in services) {
        if (service.uuid.toString() == serviceUUID) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == characteristicUUID) {
              var hexList= convertHexStringToList(off_commad_hex_String);
              if (kDebugMode) {
                if (kDebugMode) {
                  print(hexList);
                }
              }
              // await characteristic.writeLarge(hexList, mtu);
              await characteristic.write(hexList); // Write data using WriteLarge extension
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error : $e');
      }
    }
  }

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
        title: 'Energy Lounger',
      ),
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image.asset(
              'assets/images/lumaflex.png',
              width: 600,
              fit: BoxFit.fitWidth,
            ),
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Data from energy lounger: ${data.value}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.red,
                      // 添加其他样式属性
                    ),
                  ),
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
        Expanded(
          flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(height: 10), // 设置按钮之间的垂直间距
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150, 50), backgroundColor: Colors.red, // 设置按钮最小尺寸为150x50
                    textStyle: TextStyle(fontSize: 16), // 设置按钮的背景色
                  ),
                  onPressed: () {
                    switchButton([20, 11, 03]);
                    // 在这里添加第二个按钮的点击事件逻辑
                    print("630nm");
                  },
                  child: Text("630mm"),
                ),
                SizedBox(height: 10), // 设置按钮之间的垂直间距
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150, 50), backgroundColor: Colors.red, // 设置按钮最小尺寸为150x50
                    textStyle: TextStyle(fontSize: 16), // 设置按钮的背景色
                  ),
                  onPressed: () {
                    switchButton([20, 12, 03]);
                    // 在这里添加第三个按钮的点击事件逻辑
                    print("630mm+850mm");
                  },
                  child: Text("630mm+850mm"),
                ),
                SizedBox(height: 10), // 设置按钮之间的垂直间距
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150, 50), backgroundColor: Colors.red, // 设置按钮最小尺寸为150x50
                    textStyle: TextStyle(fontSize: 16), // 设置按钮的背景色
                  ),
                  onPressed: () {
                    switchButton([20, 13, 03]);
                    // 在这里添加第四个按钮的点击事件逻辑
                    print("630mm+940mm");
                  },
                  child: Text("630mm+940mm"),
                ),
                SizedBox(height: 10), // 设置按钮之间的垂直间距
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150, 50), backgroundColor: Colors.red, // 设置按钮最小尺寸为150x50
                    textStyle: TextStyle(fontSize: 16), // 设置按钮的背景色
                  ),
                  onPressed: () {
                    switchButton([20, 14, 03]);
                    // 在这里添加第五个按钮的点击事件逻辑
                    print("630nm+850mm+940mm");
                  },
                  child: Text("630nm+850mm+940mm"),
                ),
                SizedBox(height: 10), // 设置按钮之间的垂直间距
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150, 50), backgroundColor: Colors.red, // 设置按钮最小尺寸为150x50
                    textStyle: TextStyle(fontSize: 16), // 设置按钮的背景色
                  ),
                  onPressed: () {
                    switchButton([20, 15, 03]);
                    // 在这里添加第五个按钮的点击事件逻辑
                    print("630nm+850mm+940mm");
                  },
                  child: Text("630nm+850mm+940mm(Constant On)"),
                ),
              ],
            ),
        ),


          ],
        ),
      ),
    );
  }
}
