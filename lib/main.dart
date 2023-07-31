// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:stock/screens/home.dart';
import 'package:stock/screens/marchandise.dart';
import 'package:stock/screens/operation.dart';
import 'package:stock/screens/principal.dart';
import 'package:stock/screens/produitDetails.dart';

import 'screens/inventaire.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const PrincipalPage());
  }
}
