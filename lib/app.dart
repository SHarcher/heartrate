// lib/app.dart
import 'package:flutter/material.dart';
import 'features/home/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VitalLens Demo',
      theme: ThemeData.dark(), // 或 light()
      debugShowCheckedModeBanner: false,
      home: const HomePage(), // ← 这里必须指向首页
    );
  }
}
