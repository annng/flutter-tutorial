import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biometric Screen')),
      body: const Center(child: Column(
        children: [
          Text('Biometric Screen'),
        ],
      )),
    );
  }
}
