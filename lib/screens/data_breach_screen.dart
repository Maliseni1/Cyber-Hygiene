import 'package:flutter/material.dart';
import '../utils/constants.dart';

class DataBreachScreen extends StatefulWidget {
  const DataBreachScreen({super.key});

  @override
  State<DataBreachScreen> createState() => _DataBreachScreenState();
}

class _DataBreachScreenState extends State<DataBreachScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _resultMessage;
  bool _isSafe = true;

  void _checkBreach() async {
    final email = _emailController.text.trim();
    
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _resultMessage = null;
    });

    // SIMULATION: Fake a network delay of 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
        // DEMO LOGIC: If email is 'pwned@test.com', trigger a breach alert
        if (email.toLowerCase() == 'pwned@test.com') {
          _isSafe = false;
          _resultMessage = "Oh no! This email was found in 3 known data breaches (Adobe, LinkedIn, Canva). Change your password immediately.";
        } else {
          _isSafe = true;
          _resultMessage = "Good news! No breaches found for this email in our database.";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Breach Checker"),
        backgroundColor: Colors.deepPurple, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.travel_explore, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 20),
            const Text(
              "Has your email been leaked?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter your email to check against our database of known data breaches.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            
            // Email Input
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email Address",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // Check Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _checkBreach,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: _isLoading 
                  ? const SizedBox(
                      height: 20, width: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Text("Check Now"),
              ),
            ),

            const SizedBox(height: 30),

            // Results Area
            if (_resultMessage != null)
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: _isSafe ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _isSafe ? Colors.green : Colors.red),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isSafe ? Icons.check_circle : Icons.warning,
                      color: _isSafe ? Colors.green : Colors.red,
                      size: 30,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        _resultMessage!,
                        style: TextStyle(
                          color: _isSafe ? Colors.green[800] : Colors.red[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}