import 'package:flutter/material.dart';
import 'auth/auth_guard.dart';

void main() {
  runApp(const NoctraApp());
}

class NoctraApp extends StatelessWidget {
  const NoctraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGuard(),
    );
  }
}
