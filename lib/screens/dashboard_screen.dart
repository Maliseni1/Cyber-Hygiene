import 'package:flutter/material.dart';
import '../services/scanner_service.dart';
import '../models/audit_result.dart';
import '../utils/constants.dart';
import '../widgets/score_circle.dart';
import 'settings_screen.dart';
import 'permission_audit_screen.dart';
import 'data_breach_screen.dart';
// Ensure this import points to the file where you put the SpywareHunterScreen class
import 'spyware_screen.dart'; 

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScannerService _scanner = ScannerService();
  List<AuditResult> _results = [];
  bool _isLoading = false;
  int _score = 100; // Default to 100 until scanned

  void _performScan() async {
    setState(() => _isLoading = true);

    try {
      // 1. Run the scan (Returns List<Application>)
      final apps = await _scanner.runFullScan();
      
      // 2. Calculate Score (Returns double, need to cast to int)
      final double rawScore = _scanner.calculateScore(apps);
      
      // 3. Convert "Apps" to "AuditResults" for the list view
      List<AuditResult> scanResults = [];
      
      // Check for suspicious apps and add them to the results list
      bool foundIssues = false;
      for (var app in apps) {
        if (_scanner.isSuspicious(app)) {
          foundIssues = true;
          scanResults.add(AuditResult(
            title: "Suspicious: ${app.appName}",
            recommendation: "Uninstall ${app.packageName} immediately.",
            isSafe: false,
          ));
        }
      }

      // If no issues found, add a "Safe" result
      if (!foundIssues) {
        scanResults.add(AuditResult(
          title: "System Safe",
          recommendation: "No known spyware signatures detected.",
          isSafe: true,
        ));
      }

      if (mounted) {
        setState(() {
          _results = scanResults;
          _score = rawScore.toInt(); // Fix: Convert double to int
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Scan failed: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _results = [
            AuditResult(
              title: "Scan Error", 
              recommendation: "Could not complete scan. Check permissions.", 
              isSafe: false
            )
          ];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.kBackgroundColor,
      appBar: AppBar(
        title: Text(AppConstants.appName, style: AppConstants.headerStyle.copyWith(fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const SettingsScreen())
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            ScoreCircle(score: _score, radius: 130.0),
            const SizedBox(height: 30),
            
            // 1. Main Security Scan Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _performScan,
              icon: const Icon(Icons.security),
              label: Text(_isLoading ? "Scanning..." : "Run Hygiene Scan"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.kPrimaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            
            const SizedBox(height: 15),

            // 2. Spyware Hunter Button
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SpywareHunterScreen()),
                );
              },
              icon: const Icon(Icons.remove_red_eye, color: AppConstants.kWarningColor),
              label: const Text("Open Spyware Hunter", style: TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppConstants.kWarningColor),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),

            const SizedBox(height: 15),

            // 3. Permission Audit Button (NEW)
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PermissionAuditScreen()),
                );
              },
              icon: const Icon(Icons.lock_person, color: Colors.blueAccent),
              label: const Text("Permission Audit Tool", style: TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blueAccent),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),

            const SizedBox(height: 20),

            // 4. NEW: Data Breach Checker Button
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DataBreachScreen()),
                );
              },
              icon: const Icon(Icons.travel_explore, color: Colors.deepPurple),
              label: const Text("Data Breach Checker", style: TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.deepPurple),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),

            const SizedBox(height: 20),
            
            // Results List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final item = _results[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppConstants.kCardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border(
                        left: BorderSide(
                          color: item.isSafe ? AppConstants.kSafeColor : AppConstants.kWarningColor,
                          width: 4
                        )
                      )
                    ),
                    child: ListTile(
                      leading: Icon(
                        item.isSafe ? Icons.check_circle : Icons.warning_amber_rounded,
                        color: item.isSafe ? AppConstants.kSafeColor : AppConstants.kWarningColor,
                      ),
                      title: Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(item.recommendation, style: const TextStyle(color: Colors.grey)),
                      ),
                    ),
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