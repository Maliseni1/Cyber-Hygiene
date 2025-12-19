import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/constants.dart';
import '../services/local_storage.dart';
import '../services/update_service.dart';
import '../utils/theme_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = "Loading...";
  final LocalStorage _storage = LocalStorage();
  final UpdateService _updateService = UpdateService();
  bool _isCheckingUpdate = false;

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

  // --- Update Feature Logic ---
  Future<void> _handleCheckUpdate() async {
    setState(() => _isCheckingUpdate = true);

    final result = await _updateService.checkForUpdate();

    setState(() => _isCheckingUpdate = false);

    if (!mounted) return;

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not connect to update server.")),
      );
      return;
    }

    if (result['updateAvailable'] == true) {
      _showUpdateDialog(result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("You are up to date!"),
          backgroundColor: AppConstants.kSafeColor,
        ),
      );
    }
  }

  void _showUpdateDialog(Map<String, dynamic> updateData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // Use Theme card color
        backgroundColor: Theme.of(context).cardColor,
        title: Text("Update Available 🚀", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Version ${updateData['latestVersion']} is available.",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              updateData['body'] ?? "Security improvements and bug fixes.",
              style: const TextStyle(color: Colors.grey),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Later"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.kPrimaryColor),
            onPressed: () {
              Navigator.pop(context);
              _updateService.launchUpdateUrl(updateData['downloadUrl']);
            },
            child: const Text("Download"),
          ),
        ],
      ),
    );
  }

  // --- Data Wipe Logic ---
  Future<void> _handleClearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text("Reset App Data?", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
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
    final currentMode = themeManager.themeMode;
    // We use the Theme colors now instead of AppConstants.kBackgroundColor
    final headerColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      // Background handled by main.dart Theme
      appBar: AppBar(
        title: Text("Settings", style: AppConstants.headerStyle.copyWith(fontSize: 20, color: headerColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: headerColor), // Back button color matches theme
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 10),

                // --- SECTION 1: APPEARANCE (NEW) ---
                _buildSectionHeader("Appearance"),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildThemeOption("System Default", ThemeMode.system, Icons.brightness_auto, currentMode),
                      Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                      _buildThemeOption("Light Mode", ThemeMode.light, Icons.wb_sunny, currentMode),
                      Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                      _buildThemeOption("Dark Mode", ThemeMode.dark, Icons.nights_stay, currentMode),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                
                // --- SECTION 2: DATA & PRIVACY ---
                _buildSectionHeader("Data & Privacy"),
                _buildTile(
                  icon: Icons.delete_forever,
                  title: "Wipe All Data",
                  subtitle: "Clear local storage and scan history",
                  iconColor: AppConstants.kDangerColor,
                  onTap: _handleClearData,
                ),
                
                const SizedBox(height: 20),

                // --- SECTION 3: ABOUT ---
                _buildSectionHeader("About"),
                _buildTile(
                  icon: Icons.system_update,
                  title: "Check for Updates",
                  subtitle: _isCheckingUpdate ? "Checking..." : "Current: $_version",
                  iconColor: Colors.purpleAccent,
                  onTap: _isCheckingUpdate ? () {} : _handleCheckUpdate,
                ),
                _buildTile(
                  icon: Icons.info_outline,
                  title: "Version Info",
                  subtitle: "Build details",
                  iconColor: Colors.blueGrey,
                  onTap: () {}, 
                ),
                _buildTile(
                  icon: Icons.shield,
                  title: "Privacy Policy",
                  subtitle: "No data leaves this device.",
                  iconColor: AppConstants.kSafeColor,
                  onTap: () {
                    // Placeholder
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
                Text("Designed & Built by", style: TextStyle(color: headerColor, fontSize: 12)),
                Text(
                  AppConstants.companyName.toUpperCase(), 
                  style: TextStyle(color: AppConstants.kPrimaryColor, fontWeight: FontWeight.bold, letterSpacing: 1.5)
                ),
                const SizedBox(height: 4),
                Text(AppConstants.copyright, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildThemeOption(String title, ThemeMode mode, IconData icon, ThemeMode currentMode) {
    final isSelected = currentMode == mode;
    return RadioListTile<ThemeMode>(
      title: Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
      secondary: Icon(icon, color: isSelected ? AppConstants.kPrimaryColor : Colors.grey),
      value: mode,
      groupValue: currentMode,
      activeColor: AppConstants.kPrimaryColor,
      onChanged: (value) => themeManager.toggleTheme(value!),
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
        color: Theme.of(context).cardColor, // Replaces AppConstants.kCardColor
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
        title: Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)), // Replaces Colors.white
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}