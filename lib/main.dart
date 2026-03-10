import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TestApiPage(),
    );
  }
}

class TestApiPage extends StatefulWidget {
  const TestApiPage({super.key});

  @override
  State<TestApiPage> createState() => _TestApiPageState();
}

class _TestApiPageState extends State<TestApiPage> {
  String message = "Chargement...";

  @override
  void initState() {
    super.initState();
    fetchMessage();
  }

  Future<void> fetchMessage() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/test'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          message = data['message'];
        });
      } else {
        setState(() {
          message = 'Erreur serveur: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        message = 'Erreur connexion: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Laravel API'),
      ),
      body: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}