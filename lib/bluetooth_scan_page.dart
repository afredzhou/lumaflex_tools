import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:lumaflex_tools/view/custom_app_bar.dart';
import 'bluetooth_command.dart';
import 'start_scan.dart';
import 'package:get/get.dart';
final List<BluetoothDevice> scanResults = <BluetoothDevice>[];
final RxBool kDebugMode = Get.find(); // 在需要的地方获取全局变量

class BluetoothScanPage extends StatefulWidget {
  const BluetoothScanPage({Key? key}) : super(key: key);

  @override
  _BluetoothScanPageState createState() => _BluetoothScanPageState();
}

class _BluetoothScanPageState extends State<BluetoothScanPage> {

  bool _isScanning = true;
  final _isConnected = false.obs;
  var deviceName = "Lumaflex".obs;
  @override
  void initState() {
    Get.put(deviceName);
    super.initState();
    _startScan();
  }

  void _connect(device) async{
    await device.connect();
    device.connectionState.listen((connectionState) {
      if (connectionState == BluetoothConnectionState.connected) {
        if (kDebugMode.value) {
          print("Connected successfully");
        }
        _isConnected.value = true;
      } else if (connectionState == BluetoothConnectionState.disconnected) {
        print("Disconnected");
        _isConnected.value = false;
      }
    });
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
    FlutterBluePlus.stopScan(); // 停止扫描
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
              child: ListView.builder(
                itemCount: scanResults.length,
                itemBuilder: (context, index) {
                  final BluetoothDevice device = scanResults[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey),
                      color: const Color(0xFFF0F0F0), // 设置背景颜色
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
                          minimumSize:
                          MaterialStateProperty.all<Size>(const Size(150, 30)),
                          // 设置按钮最小尺寸为150x50
                          fixedSize: MaterialStateProperty.all<Size>(const Size(150, 30)),
                          backgroundColor: MaterialStateProperty.all(Colors.red),
                          textStyle: MaterialStateProperty.resolveWith<TextStyle>(
                                (states) =>
                                const TextStyle(fontSize: 16), // 设置按钮文本的字体大小为16
                          ),
                        ),
                        onPressed: () {
                          if (_isConnected.value) {
                            _disconnect(device);
                          } else {
                            _connect(device);
                            Get.to(BluetoothCommand(device: device));
                          }
                        },
                        child: Obx(() => Text(_isConnected.value ? "Disconnect" : "Connect"))
                      ),
                    ),
                  );
                },
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


Future<void> _startScan() async {
  scanResults.clear(); // 清空设备列表
  BluetoothDevice device = await startScan(); // 扫描设备
  if (!scanResults.contains(device)) {
    scanResults.add(device); // 将设备添加到 scanResults 列表中
  }
}
