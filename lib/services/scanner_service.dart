import 'package:device_apps/device_apps.dart';

class ScannerService {
  // 1. Fetch all installed apps
  Future<List<Application>> getAllApps() async {
    try {
      return await DeviceApps.getInstalledApplications(
        includeAppIcons: true,
        includeSystemApps: false,
        onlyAppsWithLaunchIntent: true,
      );
    } catch (e) {
      print("Error fetching apps: $e");
      return [];
    }
  }

  // 2. Identify suspicious apps
  bool isSuspicious(Application app) {
    final suspiciousKeywords = ['spy', 'track', 'monitor', 'hack', 'logger'];
    for (var keyword in suspiciousKeywords) {
      if (app.packageName.toLowerCase().contains(keyword) || 
          app.appName.toLowerCase().contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  // --- NEW METHODS ADDED BELOW ---

  // 3. Wrapper for 'runFullScan' (called by Dashboard)
  Future<List<Application>> runFullScan() async {
    // Just calls getAllApps(), but matches the name your Dashboard expects
    return await getAllApps();
  }

  // 4. Calculate Score Logic (called by Dashboard)
  double calculateScore(List<Application> apps) {
    int suspiciousFound = 0;
    for (var app in apps) {
      if (isSuspicious(app)) {
        suspiciousFound++;
      }
    }

    double score = 100.0;
    if (apps.isNotEmpty) {
      // Deduct 10 points for every suspicious app found
      score = 100.0 - (suspiciousFound * 10.0);
      if (score < 0) score = 0;
    }
    return score;
  }
}