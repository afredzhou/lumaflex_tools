
import 'package:flutter/material.dart';
import 'package:lumaflex_tools/view/custom_app_bar.dart';
import 'bytesToHexString.dart';
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
    "开始", "结束", "暂停", '关机', '平衡调光', '弹力调光', '集中调光', '冥想调光','监听'];
  final Function(String) onCommandSent = (command) => print('Command sent: $command');
  var data = "".obs;
  static const serviceUUID = '0000fff0-0000-1000-8000-00805f9b34fb';
  static const characteristicUUID = '0000fffb-0000-1000-8000-00805f9b34fb';
  static const readCharacteristicUUID = '0000fffa-0000-1000-8000-00805f9b34fb';

  @override
  void initState() {
    super.initState();
     Future.delayed(const Duration(seconds: 1), () async {
      final result = await startNotify(widget.device, serviceUUID, readCharacteristicUUID);

       if (result != null) {
        data.value = result as String;
       } else {
        // 处理值为 null 的情况
        // 可以提供默认值或采取其他逻辑
        data.value = ''; // 设置默认值为空字符串
      }
      });

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


              kDebugMode.value ? print(hexList) : null;


              // await characteristic.writeLarge(hexList, mtu);
              await characteristic.write(hexList); // Write data using WriteLarge extension
            }
          }
        }
      }
    } catch (e) {

      kDebugMode.value ? print('Error : $e'):null;

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
                  Text(//
                    'Data from ${deviceName.value}：${data.value} ',
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
            Container(
              width: 500,
              height: 800,
              child: ListView.builder(
                itemCount: buttonLabels.length,
                itemBuilder: (BuildContext context, int index) {
                  final label = buttonLabels[index];
                  return ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red), // 设置背景颜色为红色
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // 设置圆角半径
                        ),
                      ),
                    ),
                    onPressed: () => onCommandSent(label),
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
