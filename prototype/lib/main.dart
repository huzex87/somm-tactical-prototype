// CRITICAL: DO NOT DEPLOY TO OPERATIONS. 
// This is a LABORATORY PROTOTYPE for functional validation only.
// Requires independent cryptographic and security audit before field use.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:somm_prototype/presentation/screens/home_screen.dart';
import 'package:somm_prototype/presentation/theme/somm_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: SommApp(),
    ),
  );
}

class SommApp extends StatelessWidget {
  const SommApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOMM Prototype',
      theme: SommTheme.darkTheme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
