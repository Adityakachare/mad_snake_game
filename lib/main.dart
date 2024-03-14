import 'package:first_app/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCyijMq91gIluz56viQBHEbyQrZ0jRjTQ8",
          authDomain: "snakegame-3ffa2.firebaseapp.com",
          projectId: "snakegame-3ffa2",
          storageBucket: "snakegame-3ffa2.appspot.com",
          messagingSenderId: "259427896052",
          appId: "1:259427896052:web:10f6ba81b13c180ae02ca1",
          measurementId: "G-DEHM6KL12B"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: ThemeData(brightness: Brightness.dark),
    );
  }
}
