import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:lumaflex_tools/view/custom_app_bar.dart';
import 'bluetooth_command.dart';
import 'start_scan.dart';
import 'package:get/get.dart';
class BluetoothController extends GetxController {
  final scanResults = RxList<BluetoothDevice>();

  void addDevice(BluetoothDevice device) {
    scanResults.add(device);
  }
}

final RxBool kDebugMode = Get.find(); // 在需要的地方获取全局变量

class BluetoothScanPage extends StatefulWidget {
  const BluetoothScanPage({Key? key}) : super(key: key);

  @override
  _BluetoothScanPageState createState() => _BluetoothScanPageState();
}

class _BluetoothScanPageState extends State<BluetoothScanPage> {


  final RxList<BluetoothDevice> scanResults = RxList<BluetoothDevice>();

  bool _isScanning = true;
  final _isConnected = false.obs;
  var deviceName = "Lumaflex".obs;
  @override
  void initState() {
    Get.put(deviceName);
    super.initState();
    _startScan();
  }
  Future<void> _startScan() async {
    if(!_isConnected.value)
      {
    scanResults.clear();
    }
  // 清空设备列表
    BluetoothDevice device = await startScan(); // 扫描设备
    if (kDebugMode.value) {
      print(device.localName);
    }
    if( !scanResults.contains(device))
    {
    scanResults.add(device);} // 添加设备到 scanResults 列表
  }

  Future<bool> _connect(device) async {
    Completer<bool> completer = Completer<bool>(); // 创建一个 Completer<bool> 对象

    await device.connect();

    device.connectionState.listen((connectionState) {
      if (connectionState == BluetoothConnectionState.connected) {
        if (kDebugMode.value) {
          print("Connected successfully");
        }
        _isConnected.value = true;
        completer.complete(true); // 完成 Future，并返回 true
      } else if (connectionState == BluetoothConnectionState.disconnected) {
        _isConnected.value = false;
        completer.complete(null); // 完成 Future，并返回 false
      }
    });

    return completer.future; // 返回 Future<bool>
  }

  void _disconnect(device) async {
    await device.disconnect();
    device.connectionState.listen((connectionState) {
      if (connectionState == BluetoothConnectionState.connected) {
        print("Connected successfully");
        _isConnected.value = true;
      } else if (connectionState == BluetoothConnectionState.disconnected) {
        print("Disconnected");
        _isConnected.value = false;
      }
    });
  }
  void _stopScan() {
    setState(() {
      _isScanning = false;
    });
    FlutterBluePlus.stopScan();
  }
  @override
  void dispose() {
    scanResults.forEach((device) => _disconnect(device)); // 断开所有连接的设备
    _stopScan();
// 停止扫描
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'ADD DEVICE',
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            Flexible(
              child: Align(
                alignment: const AlignmentDirectional(0, 0),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: const BoxDecoration(
                    color: Colors.black, // 设置背景颜色
                  ),
                  alignment: const AlignmentDirectional(0, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/Scan_Result.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Nearby Devices",
                    style: TextStyle(
                      color: Colors.grey, // 设置第一个文本字体颜色
                      fontSize: 25.0,
                    ),
                  ),
                  Text(
                    _isScanning ? "Scanning..." : "Not scanning",
                    style: const TextStyle(
                      color: Colors.blue, // 设置第二个文本字体颜色
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(
                      () =>
                    ListView.builder(
                    itemCount: scanResults.length,
                    itemBuilder: (context, index) {
                      final BluetoothDevice device = scanResults[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.grey),
                          color: const Color(0xFFF0F0F0),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.bluetooth,
                            color: Colors.black,
                          ),
                          title: Text(
                            device.localName,
                            style: const TextStyle(color: Colors.black),
                          ),
                          subtitle: Text(
                            device.remoteId.toString(),
                            style: const TextStyle(color: Colors.black),
                          ),
                          trailing: ElevatedButton(
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all<Size>(const Size(150, 30)),
                              fixedSize: MaterialStateProperty.all<Size>(const Size(150, 30)),
                              backgroundColor: MaterialStateProperty.all(Colors.red),
                              textStyle: MaterialStateProperty.resolveWith<TextStyle>(
                                    (states) => const TextStyle(fontSize: 16),
                              ),
                            ),
                            onPressed: () async {
                              if (_isConnected.value) {
                                _disconnect(device);
                              } else {
                                _connect(device).then((value) {
                                  value == true ? Future.delayed(Duration(seconds: 1), () {
                                    Get.to(BluetoothCommand(device: device));
                                  }) : null;
                                });
                              }
                            },
                            child: Obx(() => Text(_isConnected.value ? "Disconnect" : "Connect")),
                          ),
                        ),
                      );
                    },
                  ),

              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(()  {
            _isScanning = !_isScanning;
            if (_isScanning) {
              _startScan();
              _isScanning = true;

            } else {
              _stopScan();
              _isScanning = false;
            }
          });
        },
        child: Icon(_isScanning ? Icons.stop : Icons.search),
      ),
    );
  }
}


