import 'package:flutter/material.dart';
import '../services/scanner_service.dart';
import '../models/audit_result.dart';
import '../utils/constants.dart';
import '../widgets/score_circle.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScannerService _scanner = ScannerService();
  List<AuditResult> _results = [];
  bool _isLoading = false;
  int _score = 0;

  void _performScan() async {
    setState(() => _isLoading = true);
    final results = await _scanner.runFullScan();
    final score = _scanner.calculateScore(results);
    
    setState(() => {
      _results = results,
      _score = score,
      _isLoading = false
    });
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
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _performScan,
              icon: const Icon(Icons.security),
              label: Text(_isLoading ? "Scanning..." : "Run Hygiene Scan"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.kPrimaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 20),
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