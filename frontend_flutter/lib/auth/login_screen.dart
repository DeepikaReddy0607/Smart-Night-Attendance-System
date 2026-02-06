import 'package:flutter/material.dart';
import '../student/student_dashboard.dart';
import '../admin/admin_dashboard.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
  }
  
  class _LoginScreenState extends State<LoginScreen>{

    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    @override
    void dispose(){
      usernameController.dispose();
      passwordController.dispose();
      super.dispose();
    }
    @override
    Widget build(BuildContext context){
      return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text('Login'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Smart Night Attendance',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Roll Number / Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final username = usernameController.text.trim();
                    final password = passwordController.text.trim();

                    if (username.isEmpty || password.isEmpty){
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter all fields ')),
                      );
                      return;
                    }
                    if(username.toLowerCase() == 'admin'){
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:(context) => const AdminDashboard(),
                        ),
                      );
                    }
                    else{
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StudentDashboard(),
                          ),
                      );
                    }
                  },
                  child: const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }