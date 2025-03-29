import 'package:feedme/database/database.dart';
import 'package:flutter/material.dart';
import 'views/_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppDatabase.initDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: AppLayout(),
    );
  }
}
