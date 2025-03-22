import 'package:feedme/database/database.dart';
import 'package:flutter/material.dart';
import 'views/_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final appDb = AppDatabase.init("feed_md.db", 1);
  AppDatabase.printSql(1);
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
