import 'package:flutter/material.dart';
import 'pages/checkin_page.dart';

void main() {
  runApp(const SRJ4App());
}

class SRJ4App extends StatelessWidget {
  const SRJ4App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SRJ-4 Demo',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const CheckInPage(),
    );
  }
}
