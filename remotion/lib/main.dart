import 'package:flutter/material.dart';
import 'progress.dart'; // Import the file you just created
// import 'theme.dart'; // Assuming you have this from your prompt

void main() {
  runApp(const ReMotionApp());
}

class ReMotionApp extends StatelessWidget {
  const ReMotionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReMotion',
      // If you have the theme file from your prompt, use: theme: reMotionTheme,
      // Otherwise, this fallback theme matches the code I wrote:
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF1E6F6B),
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
      ),
      home: const ProgressPage(),
    );
  }
}