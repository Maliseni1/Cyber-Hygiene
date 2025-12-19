import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import '../services/scanner_service.dart'; // Import the service we just made

class SpywareHunterScreen extends StatefulWidget {
  const SpywareHunterScreen({super.key});

  @override
  State<SpywareHunterScreen> createState() => _SpywareHunterScreenState();
}

class _SpywareHunterScreenState extends State<SpywareHunterScreen> {
  final ScannerService _scannerService = ScannerService();
  
  bool _isLoading = true; // Controls the spinner
  List<Application> _apps = [];
  int _suspiciousCount = 0;
  double _safetyScore = 0; // Will be 0.0 to 100.0

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    try {
      // 1. Fetch apps
      final apps = await _scannerService.getAllApps();
      
      // 2. Analyze them
      int suspiciousFound = 0;
      for (var app in apps) {
        if (_scannerService.isSuspicious(app)) {
          suspiciousFound++;
        }
      }

      // 3. Calculate Score (Percentage)
      // If 0 suspicious apps, score is 100%. 
      // Each suspicious app drops the score.
      double score = 100.0;
      if (apps.isNotEmpty) {
        // Simple formula: subtract 10 points for every suspicious app
        score = 100.0 - (suspiciousFound * 10.0);
        if (score < 0) score = 0;
      }

      // 4. Update UI
      if (mounted) {
        setState(() {
          _apps = apps;
          _suspiciousCount = suspiciousFound;
          _safetyScore = score;
        });
      }
    } catch (e) {
      print("Error during scan: $e");
      // Optional: Show a snackbar error here
    } finally {
      // --- THE CRITICAL FIX ---
      // This block runs NO MATTER WHAT. 
      // It ensures the spinner stops spinning.
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Spyware Hunter")),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Scanning device..."),
                ],
              ),
            )
          : Column(
              children: [
                // --- SCORE SECTION ---
                Container(
                  padding: const EdgeInsets.all(20),
                  color: _safetyScore > 80 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  child: Column(
                    children: [
                      const Text("Device Safety Score", style: TextStyle(fontSize: 18)),
                      Text(
                        "${_safetyScore.toStringAsFixed(0)}%", // Shows "90%"
                        style: TextStyle(
                          fontSize: 48, 
                          fontWeight: FontWeight.bold,
                          color: _safetyScore > 80 ? Colors.green : Colors.red,
                        ),
                      ),
                      Text("Found $_suspiciousCount suspicious apps"),
                    ],
                  ),
                ),
                
                // --- LIST SECTION ---
                Expanded(
                  child: ListView.builder(
                    itemCount: _apps.length,
                    itemBuilder: (context, index) {
                      Application app = _apps[index];
                      bool isBad = _scannerService.isSuspicious(app);
                      
                      return ListTile(
                        leading: app is ApplicationWithIcon
                            ? Image.memory(app.icon, width: 40)
                            : const Icon(Icons.android),
                        title: Text(app.appName),
                        subtitle: Text(app.packageName),
                        trailing: isBad 
                            ? const Icon(Icons.warning, color: Colors.red)
                            : const Icon(Icons.check_circle, color: Colors.green),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}