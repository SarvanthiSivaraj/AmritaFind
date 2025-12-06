import 'package:flutter/material.dart';
import 'pages/home_page.dart';


void main() => runApp(const MyApp());


class MyApp extends StatelessWidget {
const MyApp({super.key});


@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'Campus Lost & Found',
debugShowCheckedModeBanner: false,
theme: ThemeData(
primarySwatch: Colors.indigo,
useMaterial3: true,
scaffoldBackgroundColor: const Color(0xFFF4F7FB),
),
home: HomePage(),
);
}}