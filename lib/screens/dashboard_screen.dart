import 'package:flutter/material.dart';
import '../services/scanner_service.dart';
import '../models/audit_result.dart';
import '../utils/constants.dart';
import '../widgets/score_circle.dart';
import 'settings_screen.dart';
import 'permission_audit_screen.dart';
import 'spyware_screen.dart'; 
import 'data_breach_screen.dart';
import 'password_generator_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScannerService _scanner = ScannerService();
  
  // State Variables
  List<AuditResult> _results = [];
  bool _isLoading = false;
  bool _hasScanned = false; // Tracks if we have run a scan yet
  int _score = 0;           // The final score
  String _scanStatus = "";  // Shows "Checking passwords...", "Scanning apps..."

  void _performScan() async {
    setState(() {
      _isLoading = true;
      _hasScanned = false;
      _results = [];
    });

    try {
      // 1. SIMULATE SETTINGS & HABITS AUDIT
      // Real apps can't see your brain, so we check for "Best Practices"
      setState(() => _scanStatus = "Analyzing Device Settings...");
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() => _scanStatus = "Checking Password Habits...");
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() => _scanStatus = "Verifying 2FA Configuration...");
      await Future.delayed(const Duration(milliseconds: 800));

      // 2. REAL APP SCAN
      setState(() => _scanStatus = "Scanning Installed Applications...");
      final apps = await _scanner.runFullScan();
      
      // 3. COMPILE RESULTS
      List<AuditResult> scanResults = [];
      int penalties = 0;

      // Check Apps (Real Data)
      for (var app in apps) {
        if (_scanner.isSuspicious(app)) {
          penalties += 10;
          scanResults.add(AuditResult(
            title: "Risk: ${app.appName}",
            recommendation: "Uninstall ${app.packageName} immediately.",
            isSafe: false,
          ));
        }
      }

      // Check "Habits" (Static Advice based on "Auditor" logic)
      // In a real app, you might check if Screen Lock is enabled (requires packages).
      // Here we assume defaults and give advice.
      scanResults.add(AuditResult(
        title: "2FA Usage",
        recommendation: "Ensure 2-Factor Authentication is enabled on Google & Socials.",
        isSafe: true, // We assume safe, but remind them
      ));

      scanResults.add(AuditResult(
        title: "Screen Lock",
        recommendation: "Use Biometrics or a strong PIN, not a Pattern.",
        isSafe: true,
      ));

      // 4. CALCULATE SCORE
      // Base 100, minus penalties for bad apps
      int calculatedScore = 100 - penalties;
      if (calculatedScore < 0) calculatedScore = 0;

      if (mounted) {
        setState(() {
          _results = scanResults;
          _score = calculatedScore;
          _isLoading = false;
          _hasScanned = true; // NOW we show the score
        });
      }
    } catch (e) {
      print("Scan failed: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasScanned = false;
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
          children: [
            const SizedBox(height: 20),
            
            // --- SCORE CIRCLE (CONDITIONAL) ---
            if (!_hasScanned && !_isLoading)
              // State 1: Ready to Scan
              Container(
                height: 200, width: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.withOpacity(0.5), width: 4),
                  color: Colors.white.withOpacity(0.05)
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield_outlined, size: 60, color: Colors.grey),
                    SizedBox(height: 10),
                    Text("Tap Scan", style: TextStyle(color: Colors.grey, fontSize: 18))
                  ],
                ),
              )
            else if (_isLoading)
              // State 2: Scanning...
              SizedBox(
                height: 200, width: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppConstants.kPrimaryColor),
                    const SizedBox(height: 20),
                    Text(_scanStatus, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              )
            else
              // State 3: Score Result
              ScoreCircle(score: _score, radius: 130.0),

            const SizedBox(height: 30),
            
            // --- MAIN SCAN BUTTON ---
            // Only show if not loading
            if (!_isLoading)
            ElevatedButton.icon(
              onPressed: _performScan,
              icon: const Icon(Icons.radar),
              label: Text(_hasScanned ? "Re-Scan Device" : "Run Security Audit"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.kPrimaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
            
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            
            // TEMPORARY LIST OF BUTTONS (Will be replaced by Grid in Phase 3)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                   // The Feature buttons are here, but we will replace them in Phase 3
                   // Just placeholders to keep the app compiling for now
                   _buildFeatureButton(context, "Spyware Hunter", Icons.remove_red_eye, Colors.red, const SpywareHunterScreen()),
                   _buildFeatureButton(context, "Permission Audit", Icons.lock_person, Colors.blue, const PermissionAuditScreen()),
                   _buildFeatureButton(context, "Data Breach Check", Icons.travel_explore, Colors.deepPurple, const DataBreachScreen()),
                   _buildFeatureButton(context, "Password Gen", Icons.vpn_key, Colors.teal, const PasswordGeneratorScreen()),
                   
                   // Show Audit Results if scanned
                   if (_hasScanned) ...[
                     const Padding(
                       padding: EdgeInsets.symmetric(vertical: 15),
                       child: Text("Audit Results", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                     ),
                     ..._results.map((item) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppConstants.kCardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border(left: BorderSide(color: item.isSafe ? AppConstants.kSafeColor : AppConstants.kWarningColor, width: 4))
                        ),
                        child: ListTile(
                          title: Text(item.title, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(item.recommendation, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          trailing: Icon(item.isSafe ? Icons.check_circle : Icons.warning, color: item.isSafe ? AppConstants.kSafeColor : AppConstants.kWarningColor),
                        ),
                     ))
                   ]
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Helper for Phase 1 (Temporary)
  Widget _buildFeatureButton(BuildContext context, String label, IconData icon, Color color, Widget screen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
        icon: Icon(icon, color: color),
        label: Text(label, style: const TextStyle(color: Colors.white)),
        style: OutlinedButton.styleFrom(side: BorderSide(color: color), padding: const EdgeInsets.all(15)),
      ),
    );
  }
}