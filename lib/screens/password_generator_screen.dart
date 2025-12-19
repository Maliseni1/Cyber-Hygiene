import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Needed for Clipboard
import 'dart:math';

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() => _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  String _generatedPassword = "";
  double _passwordLength = 12;
  bool _includeUppercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;

  // Logic to generate the random password
  void _generatePassword() {
    const lowercase = "abcdefghijklmnopqrstuvwxyz";
    const uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const numbers = "0123456789";
    const symbols = "!@#\$%^&*()_+-=[]{}|;:,.<>?";

    String chars = lowercase;
    if (_includeUppercase) chars += uppercase;
    if (_includeNumbers) chars += numbers;
    if (_includeSymbols) chars += symbols;

    Random rnd = Random();
    String tempPassword = "";
    
    // Ensure at least one character from each selected set is included
    // (This prevents a "numbers only" password if you selected all options)
    if (_includeUppercase) tempPassword += uppercase[rnd.nextInt(uppercase.length)];
    if (_includeNumbers) tempPassword += numbers[rnd.nextInt(numbers.length)];
    if (_includeSymbols) tempPassword += symbols[rnd.nextInt(symbols.length)];

    // Fill the rest randomly
    while (tempPassword.length < _passwordLength) {
      tempPassword += chars[rnd.nextInt(chars.length)];
    }

    // Shuffle the result so the forced characters aren't always at the start
    List<String> splitPass = tempPassword.split('')..shuffle();
    
    setState(() {
      _generatedPassword = splitPass.join('');
    });
  }

  void _copyToClipboard() {
    if (_generatedPassword.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _generatedPassword));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password copied to clipboard!")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _generatePassword(); // Generate one immediately on open
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Secure Password Generator"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Password Display Area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.teal),
              ),
              child: SelectableText(
                _generatedPassword,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  letterSpacing: 2
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // Copy Button
            ElevatedButton.icon(
              onPressed: _copyToClipboard,
              icon: const Icon(Icons.copy),
              label: const Text("Copy Password"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),

            // Settings
            const Align(
              alignment: Alignment.centerLeft, 
              child: Text("Configuration", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
            ),
            
            // Length Slider
            Row(
              children: [
                const Text("Length: "),
                Text("${_passwordLength.toInt()}", style: const TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Slider(
                    value: _passwordLength,
                    min: 8,
                    max: 32,
                    divisions: 24,
                    activeColor: Colors.teal,
                    onChanged: (value) {
                      setState(() {
                        _passwordLength = value;
                      });
                    },
                  ),
                ),
              ],
            ),

            // Toggles
            SwitchListTile(
              title: const Text("Include Uppercase (A-Z)"),
              activeColor: Colors.teal,
              value: _includeUppercase,
              onChanged: (val) => setState(() => _includeUppercase = val),
            ),
            SwitchListTile(
              title: const Text("Include Numbers (0-9)"),
              activeColor: Colors.teal,
              value: _includeNumbers,
              onChanged: (val) => setState(() => _includeNumbers = val),
            ),
            SwitchListTile(
              title: const Text("Include Symbols (!@#)"),
              activeColor: Colors.teal,
              value: _includeSymbols,
              onChanged: (val) => setState(() => _includeSymbols = val),
            ),

            const Spacer(),

            // Generate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _generatePassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.black87,
                ),
                child: const Text("Generate New Password", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}