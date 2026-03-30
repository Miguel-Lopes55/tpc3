import 'package:flutter/material.dart';
import 'pantry_screen.dart';
import 'models/pantry_item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Example pantry items
    final pantryItems = [
      PantryItem(
        name: 'Apples',
        imagePath: 'assets/images/apple.png',
        addedDate: DateTime.now().subtract(const Duration(days: 2)),
        expirationDate: DateTime.now().add(const Duration(days: 20)),
      ),
      PantryItem(
        name: 'Bananas',
        imagePath: 'assets/images/banana.png',
        addedDate: DateTime.now().subtract(const Duration(days: 1)),
        expirationDate: DateTime.now().add(const Duration(days: 3)),
      ),
      PantryItem(
        name: 'Carrots',
        imagePath: 'assets/images/carrots.png',
        addedDate: DateTime.now(),
        expirationDate: DateTime.now().add(const Duration(days: 7)),
        
      ),
      PantryItem(
        name: 'joe',
        imagePath: 'assets/images/carrots.png',
        addedDate: DateTime.now(),
        expirationDate: DateTime.now().add(const Duration(days: 0)),

      ),
      PantryItem(
        name: 'joe',
        imagePath: 'assets/images/carrots.png',
        addedDate: DateTime.now(),
        expirationDate: DateTime.now().add(const Duration(days: 7)),

      ),
      PantryItem(
        name: 'joe',
        imagePath: 'assets/images/carrots.png',
        addedDate: DateTime.now(),
        expirationDate: DateTime.now().add(const Duration(days: 7)),

      ),
      PantryItem(
        name: 'joe',
        imagePath: 'assets/images/carrots.png',
        addedDate: DateTime.now(),
        expirationDate: DateTime.now().add(const Duration(days: 7)),

      ),
      // Add more items as needed
    ];

    return MaterialApp(
      title: 'Pantry App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: PantryScreen(items: pantryItems),
    );
  }
}