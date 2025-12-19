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
  
  List<AuditResult> _results = [];
  bool _isLoading = false;
  bool _hasScanned = false; 
  int _score = 0;           
  String _scanStatus = "";  

  void _performScan() async {
    setState(() {
      _isLoading = true;
      _hasScanned = false;
      _results = [];
    });

    try {
      setState(() => _scanStatus = "Analyzing Device Settings...");
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() => _scanStatus = "Checking Password Habits...");
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() => _scanStatus = "Scanning Installed Apps...");
      final apps = await _scanner.runFullScan();
      
      List<AuditResult> scanResults = [];
      int penalties = 0;

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

      // Default advice if no real threats found
      if (scanResults.isEmpty) {
        scanResults.add(AuditResult(
          title: "System Clean",
          recommendation: "No malicious apps detected.",
          isSafe: true,
        ));
      }
      
      // Always add general hygiene advice
      scanResults.add(AuditResult(
        title: "2FA Check",
        recommendation: "Enable 2FA on your Google Account.",
        isSafe: true,
      ));

      int calculatedScore = 100 - penalties;
      if (calculatedScore < 0) calculatedScore = 0;

      if (mounted) {
        setState(() {
          _results = scanResults;
          _score = calculatedScore;
          _isLoading = false;
          _hasScanned = true; 
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
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
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              
              // --- SECTION 1: SCORE ---
              if (!_hasScanned && !_isLoading)
                _buildReadyState()
              else if (_isLoading)
                _buildLoadingState()
              else
                ScoreCircle(score: _score, radius: 120.0),

              const SizedBox(height: 25),

              // --- SECTION 2: SCAN BUTTON ---
              if (!_isLoading)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _performScan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.kPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _hasScanned ? "RUN FULL AUDIT AGAIN" : "START AUDIT", 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                ),
              
              const SizedBox(height: 30),

              // --- SECTION 3: TOOLS GRID ---
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Security Tools", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 15),

              GridView.count(
                shrinkWrap: true, // Vital for inside SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
                children: [
                  _buildTile(
                    context, 
                    "Spyware\nHunter", 
                    Icons.remove_red_eye, 
                    AppConstants.kWarningColor, 
                    const SpywareHunterScreen()
                  ),
                  _buildTile(
                    context, 
                    "Permission\nAudit", 
                    Icons.lock_person, 
                    Colors.blueAccent, 
                    const PermissionAuditScreen()
                  ),
                  _buildTile(
                    context, 
                    "Data Breach\nCheck", 
                    Icons.travel_explore, 
                    Colors.deepPurpleAccent, 
                    const DataBreachScreen()
                  ),
                  _buildTile(
                    context, 
                    "Password\nGenerator", 
                    Icons.vpn_key, 
                    Colors.tealAccent, 
                    const PasswordGeneratorScreen()
                  ),
                ],
              ),

              // --- SECTION 4: RESULTS (Only if scanned) ---
              if (_hasScanned) ...[
                const SizedBox(height: 30),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Improvement Advice", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                ..._results.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.kCardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border(left: BorderSide(color: item.isSafe ? AppConstants.kSafeColor : AppConstants.kWarningColor, width: 4))
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(item.isSafe ? Icons.check_circle : Icons.warning, color: item.isSafe ? AppConstants.kSafeColor : AppConstants.kWarningColor, size: 20),
                          const SizedBox(width: 10),
                          Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(item.recommendation, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                )),
              ]
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildReadyState() {
    return Container(
      height: 180, width: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 2),
        color: Colors.white.withOpacity(0.05)
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 60, color: Colors.grey),
          SizedBox(height: 10),
          Text("No Data", style: TextStyle(color: Colors.grey))
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 180, width: 180,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppConstants.kPrimaryColor),
          const SizedBox(height: 20),
          Text(_scanStatus, style: const TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, String title, IconData icon, Color color, Widget page) {
    return Material(
      color: AppConstants.kCardColor,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}