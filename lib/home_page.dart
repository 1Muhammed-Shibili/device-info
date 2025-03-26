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
  String serialNumber = "Fetching...";
  String totalStorage = "Fetching...";
  String availableStorage = "Fetching...";

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    final result = await callNativeMethod("deviceId");
    final total = await callNativeMethod("getTotalStorage");
    final available = await callNativeMethod("getAvailableStorage");

    setState(() {
      serialNumber = result;
      totalStorage = total;
      availableStorage = available;
    });
  }

  Future<String> callNativeMethod(String method) async {
    const platform = MethodChannel('device/info');
    try {
      return await platform.invokeMethod(method);
    } catch (e) {
      return 'Error';
    }
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
          ? showAndroidInfo()
          : Platform.isIOS
              ? showIOSInfo()
              : Container(),
    );
  }

  Widget showAndroidInfo() {
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
                item('Android Serial', serialNumber),
                item('Android Is Physical', info.isPhysicalDevice.toString()),
                item('Android SDK Int', info.version.sdkInt.toString()),
                item('Total Storage', totalStorage),
                item('Available Storage', availableStorage),
              ],
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget showIOSInfo() {
    return FutureBuilder(
      future: deviceInfoPlugin.iosInfo,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
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

  Widget item(String name, String value) {
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
