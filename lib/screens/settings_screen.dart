import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/constants.dart';
import '../services/local_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = "Loading...";
  final LocalStorage _storage = LocalStorage();

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = "${info.version} (Build ${info.buildNumber})";
    });
  }

  Future<void> _handleClearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.kCardColor,
        title: const Text("Reset App Data?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "This will wipe all your scan history and preferences. This action cannot be undone.",
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Wipe Data", style: TextStyle(color: AppConstants.kDangerColor)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.clearAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All data erased securely.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.kBackgroundColor,
      appBar: AppBar(
        title: Text("Settings", style: AppConstants.headerStyle.copyWith(fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 20),
                _buildSectionHeader("Data & Privacy"),
                _buildTile(
                  icon: Icons.delete_forever,
                  title: "Wipe All Data",
                  subtitle: "Clear local storage and scan history",
                  iconColor: AppConstants.kDangerColor,
                  onTap: _handleClearData,
                ),
                
                const SizedBox(height: 20),
                _buildSectionHeader("About"),
                _buildTile(
                  icon: Icons.info_outline,
                  title: "Version",
                  subtitle: _version,
                  iconColor: Colors.blueGrey,
                  onTap: () {}, 
                ),
                _buildTile(
                  icon: Icons.shield,
                  title: "Privacy Policy",
                  subtitle: "No data leaves this device.",
                  iconColor: AppConstants.kSafeColor,
                  onTap: () {
                    // TODO: Show Privacy Policy
                  },
                ),
              ],
            ),
          ),
          // -- Chiza Labs Branding Footer --
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Column(
              children: [
                const Icon(Icons.code, size: 16, color: Colors.grey),
                const SizedBox(height: 8),
                Text("Designed & Built by", style: AppConstants.bodyStyle),
                Text(AppConstants.companyName.toUpperCase(), style: AppConstants.brandingStyle),
                const SizedBox(height: 4),
                Text(AppConstants.copyright, style: AppConstants.brandingStyle.copyWith(fontSize: 10)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppConstants.kPrimaryColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppConstants.kCardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}