import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:storekit_external_purchase/storekit_external_purchase.dart';
import 'package:storekit_external_purchase/storekit_external_purchase_platform_interface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _plugin = StorekitExternalPurchase();

  String _countryCode = 'Unknown';
  bool _isExternalPurchaseAvailable = false;
  String _externalPurchaseResult = 'Not attempted';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializePlatformState();
  }

  Future<void> _initializePlatformState() async {
    try {
      final countryCode = await _plugin.getCountryCode() ?? 'Unknown';
      final isAvailable = await _plugin.isExternalPurchaseAvailable();

      if (!mounted) return;

      setState(() {
        _countryCode = countryCode;
        _isExternalPurchaseAvailable = isAvailable;
      });
    } on PlatformException {
      if (!mounted) return;
      setState(() {
        _countryCode = 'Failed to get country code';
        _isExternalPurchaseAvailable = false;
      });
    }
  }

  Future<void> _handlePresentExternalPurchase() async {
    setState(() => _isLoading = true);

    try {
      final result = await _plugin.showNotice(NoticeType.browser);

      if (!mounted) return;

      setState(() {
        _externalPurchaseResult = 'Result: ${result.value}, Accepted: ${result == NoticeResult.continued}';
        _isLoading = false;
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _externalPurchaseResult = 'Error: ${e.message} ${e.details}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('StoreKit External Purchase Example')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                title: 'getCountryCode()',
                child: Text('Country Code: $_countryCode', style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'isExternalPurchaseAvailable()',
                child: Text('Available: $_isExternalPurchaseAvailable', style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'showNotice(NoticeType.browser)',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Result: $_externalPurchaseResult', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handlePresentExternalPurchase,
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Show Notice'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        ),
      ],
    );
  }
}
