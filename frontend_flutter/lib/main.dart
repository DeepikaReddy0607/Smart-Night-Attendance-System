import 'package:flutter/material.dart';
import 'auth/login_screen.dart';

void main(){
  runApp(const NightAttendanceApp());
}

class NightAttendanceApp extends StatelessWidget{
  const NightAttendanceApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title:'Smart Night Attendance',
      home: const LoginScreen(),
    );
  }
}