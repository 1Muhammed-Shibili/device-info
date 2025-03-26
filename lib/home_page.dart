import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final deviceInfoPlugin = DeviceInfoPlugin();
  void initState() {
    init();
    super.initState();
  }

  init() async {
    final result = await callNativeMethod();
    log(result);
  }

  Future<String> callNativeMethod() async {
    const platform = MethodChannel('device/info');
    try {
      return await platform.invokeMethod('deviceId');
    } catch (e) {
      return '';
    }
  }

  String getTotalStorage() {
    var totalSpace = File("/").statSync().size;
    return '${(totalSpace / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String getAvailableStorage() {
    var freeSpace = File("/").statSync().size;
    return '${(freeSpace / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Device Info',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Platform.isAndroid
          ? showAndoridInfo()
          : Platform.isIOS
              ? showIOSInfo()
              : Container(),
    );
  }

  showAndoridInfo() {
    return FutureBuilder(
      future: deviceInfoPlugin.androidInfo,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        } else if (snapshot.hasData) {
          AndroidDeviceInfo info = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                item('Android Model', info.model),
                item('Android Brand', info.brand),
                item('Android Device', info.device),
                item('Android Hardware', info.hardware),
                item('Android Host', info.host),
                item('Android ID', info.id),
                item('Android Serial', info.serialNumber ?? 'N/A'),
                item('Android Is Physical', info.isPhysicalDevice.toString()),
                item('Android SDK Int', info.version.sdkInt.toString()),
                // item('IMEI (If Available)', deviceId),
                item('Total Storage', getTotalStorage()),
                item('Available Storage', getAvailableStorage())
              ],
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  showIOSInfo() {
    return FutureBuilder(
      future: deviceInfoPlugin.iosInfo,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        } else if (snapshot.hasData) {
          IosDeviceInfo info = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                item('iOS Name', info.name),
                item('iOS System Name', info.systemName),
                item('iOS System Version', info.systemVersion),
                item('iOS Model', info.model),
                item('iOS Is Physical', info.isPhysicalDevice.toString()),
              ],
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  item(String name, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          SizedBox(height: 7),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
