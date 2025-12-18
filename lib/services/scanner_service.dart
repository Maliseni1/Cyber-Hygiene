import 'dart:async';
import 'package:flutter/services.dart';
import '../models/audit_result.dart';

class ScannerService {
  // Matches the channel name in MainActivity.kt
  static const platform = MethodChannel('com.Maliseni1.cyber_hygiene/scan');

  Future<List<AuditResult>> runFullScan() async {
    try {
      // Call the Native Kotlin code
      final List<dynamic> resultList = await platform.invokeMethod('getSecurityStatus');

      // Parse the JSON-like List<Map> coming from Kotlin
      return resultList.map((item) {
        final Map<dynamic, dynamic> map = item;
        return AuditResult(
          title: map['title'] ?? "Unknown Check",
          isSafe: map['isSafe'] ?? false,
          recommendation: map['recommendation'] ?? "No advice available.",
        );
      }).toList();

    } on PlatformException catch (e) {
      // Fallback if the native call fails
      return [
        AuditResult(
          title: "Scan Error",
          isSafe: false,
          recommendation: "Could not access device settings: ${e.message}",
        )
      ];
    }
  }

  int calculateScore(List<AuditResult> results) {
    if (results.isEmpty) return 0;
    int safeCount = results.where((r) => r.isSafe).length;
    return ((safeCount / results.length) * 100).round();
  }
}