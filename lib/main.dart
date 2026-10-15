import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Aggiungi questo import
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inserisci qui i tuoi dati da Supabase
  await Supabase.initialize(
    url: 'https://gunnepuqscpenstxivtx.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd1bm5lcHVxc2NwZW5zdHhpdnR4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE5MDY5MjgsImV4cCI6MjEwNzQ4MjkyOH0.0Sg54j2e1zei1tEJHNn57QbCekDPRDxcWowVl0-GRzY',
  );

  runApp(
    const ProviderScope(
      child: EasyShoppingApp(),
    ),
  );
}
class EasyShoppingApp extends StatelessWidget {
  const EasyShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Shopping',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}