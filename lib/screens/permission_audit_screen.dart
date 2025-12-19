import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import '../services/scanner_service.dart';
import '../utils/constants.dart';

class PermissionAuditScreen extends StatefulWidget {
  const PermissionAuditScreen({super.key});

  @override
  State<PermissionAuditScreen> createState() => _PermissionAuditScreenState();
}

class _PermissionAuditScreenState extends State<PermissionAuditScreen> {
  final ScannerService _scannerService = ScannerService();
  List<Application> _apps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    // Reuse our existing service to fetch apps
    final apps = await _scannerService.getAllApps();
    
    // Sort apps alphabetically
    apps.sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));

    if (mounted) {
      setState(() {
        _apps = apps;
        _isLoading = false;
      });
    }
  }

  void _openAppSettings(String packageName) {
    DeviceApps.openAppSettings(packageName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Permission Audit"),
        backgroundColor: AppConstants.kPrimaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.withOpacity(0.1),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Tap any app to open its system settings and manually revoke dangerous permissions like Camera, Mic, or Location.",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _apps.length,
                    itemBuilder: (context, index) {
                      Application app = _apps[index];
                      return ListTile(
                        leading: app is ApplicationWithIcon
                            ? Image.memory(app.icon, width: 40)
                            : const Icon(Icons.android),
                        title: Text(app.appName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(app.packageName, style: const TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.settings, color: Colors.grey),
                        onTap: () => _openAppSettings(app.packageName),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}