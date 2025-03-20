import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: const Center(
        child: Text(
          "Home",
          style: TextStyle(fontSize: 24),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showInputDialog(context);
        },
        foregroundColor: Colors.white,
        child: const Icon(Icons.search),
      ),
    );
  }

  void _showInputDialog(BuildContext context) {
    final TextEditingController codeController = TextEditingController();
    String errorMessage = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter rock code"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PinCodeTextField(
                controller: codeController,
                appContext: context,
                length: 5,
                obscureText: false,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
                onChanged: (value) {
                  codeController.text = value.toUpperCase();
                  errorMessage = '';
                },
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeColor: Colors.green,
                  selectedColor: Colors.lightGreen,
                  inactiveColor: Colors.grey,
                ),
              ),
              // Display error message if any
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),

            TextButton(
              onPressed: () {
                String code = codeController.text;
                if (code.length == 5) {
                  print("Entered code: $code"); // DEBUG
                  Navigator.of(context).pop();
                } else {
                  errorMessage = "Please enter a valid 5-digit code";
                  (context as Element).markNeedsBuild();
                }
              },
              child: const Text("Search"),
            ),
          ],
        );
      },
    );
  }
}
