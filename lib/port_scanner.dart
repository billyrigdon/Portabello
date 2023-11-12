import 'package:flutter/services.dart';

class PortScanner {
  static const _channel = MethodChannel('com.example.portabello/channel');

  /// Scans ports on the given IP address within the specified range.
  /// 
  /// [ipAddress] is the target IP address for scanning.
  /// [startPort] is the starting port number in the range.
  /// [endPort] is the ending port number in the range.
  /// 
  /// Returns a string containing the scan results.
  static Future<String> scanPorts(String ipAddress, int startPort, int endPort) async {
    try {
      final String result = await _channel.invokeMethod('scanPorts', {
        'ipAddress': ipAddress,
        'startPort': startPort,
        'endPort': endPort,
      });
      return result;
    } on PlatformException catch (e) {
      // Handle any exceptions thrown by the platform-specific code
      return "Failed to scan ports: '${e.message}'.";
    }
  }
}
