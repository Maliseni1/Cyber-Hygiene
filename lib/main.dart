import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(); // Reserved for Phase 5
  runApp(const CyberHygieneApp());
}

class CyberHygieneApp extends StatelessWidget {
  const CyberHygieneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: AppConstants.kPrimaryColor,
        scaffoldBackgroundColor: AppConstants.kBackgroundColor,
      ),
      home: const DashboardScreen(),
    );
  }
}