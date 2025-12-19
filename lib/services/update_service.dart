import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  // CONFIGURATION: Update these to match your actual GitHub URL
  final String repoOwner = "Maliseni1"; 
  final String repoName = "cyber_hygiene";

  Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      // 1. Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // 2. Fetch latest release from GitHub API
      final url = Uri.parse("https://api.github.com/repos/$repoOwner/$repoName/releases/latest");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final releaseData = json.decode(response.body);
        String latestTag = releaseData['tag_name'];

        // Remove 'v' prefix if present (e.g., "v1.0.1" -> "1.0.1")
        if (latestTag.startsWith('v')) {
          latestTag = latestTag.substring(1);
        }

        // 3. Simple Version Comparison
        // (For production, consider a more robust semantic version parser)
        if (_isNewerVersion(latestTag, currentVersion)) {
            // Find the APK download asset
            String? downloadUrl;
            final List assets = releaseData['assets'];
            if (assets.isNotEmpty) {
                // Tries to find an .apk file, otherwise falls back to the html_url (release page)
                final apkAsset = assets.firstWhere(
                    (asset) => asset['name'].toString().endsWith('.apk'),
                    orElse: () => null,
                );
                downloadUrl = apkAsset != null ? apkAsset['browser_download_url'] : releaseData['html_url'];
            }

            return {
                "updateAvailable": true,
                "latestVersion": latestTag,
                "downloadUrl": downloadUrl ?? releaseData['html_url'],
                "body": releaseData['body'] // The release notes
            };
        }
      }
      return {"updateAvailable": false};
    } catch (e) {
      // Fail silently or log error
      print("Update check failed: $e");
      return null;
    }
  }

  // Helper to compare "1.0.1" vs "1.0.0"
  bool _isNewerVersion(String latest, String current) {
    List<int> lParts = latest.split('.').map(int.parse).toList();
    List<int> cParts = current.split('.').map(int.parse).toList();

    for (int i = 0; i < lParts.length && i < cParts.length; i++) {
      if (lParts[i] > cParts[i]) return true;
      if (lParts[i] < cParts[i]) return false;
    }
    // If lengths differ (1.0 vs 1.0.1), usually longer is newer
    return lParts.length > cParts.length;
  }

  Future<void> launchUpdateUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}