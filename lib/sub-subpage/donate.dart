import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import the services package

class DonatePage extends StatelessWidget {
  // Define your bank details
  final String bankDetails = '''
Bank Name: Zenith Bank
Account Name: Patrick Joseph
Account Number: 2262076881
Swift Code: ZEIBNGLAXXX
''';

  const DonatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donate'),
        
      ),
      body: SingleChildScrollView(
        // Wrap the Column with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Support Us',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'If you would like to support our work, please consider making a donation. Here are our bank details:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Text(
                bankDetails,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Copy the bank details to the clipboard
                    Clipboard.setData(ClipboardData(text: bankDetails))
                        .then((_) {
                      // Show a snackbar or a dialog to inform the user
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Bank details copied to clipboard!')),
                      );
                    });
                  },
                  child: const Text('Copy Bank Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
