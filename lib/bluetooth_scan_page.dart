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
class ScannedDevice {
  final BluetoothDevice device;
  final DateTime time;
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScannedDevice &&
        other.device.remoteId == device.remoteId;
  }
  @override
  int get hashCode => device.remoteId.hashCode;
  ScannedDevice(this.device, this.time);
}
final RxBool kDebugMode = Get.find(); // 在需要的地方获取全局变量
class BluetoothScanPage extends StatefulWidget {
  const BluetoothScanPage({Key? key}) : super(key: key);
  @override
  _BluetoothScanPageState createState() => _BluetoothScanPageState();
}

class _BluetoothScanPageState extends State<BluetoothScanPage> {
  final RxList<ScannedDevice> scanResults = RxList<ScannedDevice>();
  bool _isScanning = false;
  final _isConnected = false.obs;
  var connectedDevices = <BluetoothDevice>[].obs;
  var deviceName = "Cerathrive".obs;
  // var deviceName = "Lumaflex".obs;
  @override
  void initState() {
    super.initState();
    Get.put(deviceName);
  }
  Future<void> _startScan() async {
    const scanTimeout = 10;
    scanResults.clear();
    // 将已连接设备添加到扫描结果
    for (BluetoothDevice device in connectedDevices) {
      // 检查是否已经在扫描结果中
      if (!scanResults.any((scanned) => scanned.device == device)) {
        // 不在结果中,才添加
        scanResults.add(ScannedDevice(device, DateTime.now()));
      }
    }
        Timer.periodic(const Duration(seconds: 1), (timer) {
          scanResults.removeWhere((device) {
            if (connectedDevices.contains(device.device)) return false;
            return DateTime.now().difference(device.time) >= const Duration(seconds: scanTimeout);
          });
        });
  // 清空设备列表
    BluetoothDevice device = await startScan(); // 扫描设备
    kDebugMode.value ? print(device.localName):null;
    if (scanResults.any((scanned) {
      return scanned == ScannedDevice(device, DateTime.now());
    })) {
      // 已包含则不添加
    } else {
      // 不包含则添加
      scanResults.add(ScannedDevice(device, DateTime.now()));
    }
  }
  Future<bool ?> _connect(device) async {
    _stopScan();
    _isConnected.value = true;
    await device.connect();
    await device.connectionState.listen((connectionState) async {
        if (connectionState == BluetoothConnectionState.connected) {
          kDebugMode.value ? print("Connected successfully") : null;
          connectedDevices.add(device);
        } else {
          _isConnected.value = false;
          connectedDevices.remove(device);
        }
      });
      return _isConnected.value;
  }
  void _disconnect(device) async {
    await device.disconnect();
    device.connectionState.listen((connectionState) {
      if (connectionState == BluetoothConnectionState.connected) {
        kDebugMode.value ? print("Connected successfully"):null;
        _isConnected.value = true;
        connectedDevices.remove(device);
      } else if (connectionState == BluetoothConnectionState.disconnected) {
        kDebugMode.value ? print("Disconnected"):null;
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
    _stopScan();
// 停止扫描
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'ADD DEVICE',
        leading:null,
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
                      final ScannedDevice scannedDevice = scanResults[index];
// 从ScannedDevice中获取BluetoothDevice
                      final BluetoothDevice device = scannedDevice.device;
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
                               await _connect(device).then((value) {
                                  value == true ? Future.delayed(const Duration(milliseconds: 500), () {
                                    Get.to(() => BluetoothCommand(device: device));

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


