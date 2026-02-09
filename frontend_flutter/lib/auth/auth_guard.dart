import 'package:flutter/material.dart';
import '../services/token_service.dart';
import 'login_screen.dart';
import '../student/student_dashboard.dart';
import '../admin/admin_dashboard.dart';

class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: TokenService.isLoggedIn(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.data!) {
          return LoginScreen();
        }

        return FutureBuilder<String?>(
          future: TokenService.getRole(),
          builder: (context, roleSnapshot) {
            if (!roleSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final role = roleSnapshot.data!.toLowerCase();

            if (role == "warden" || role == "admin") {
              return const AdminDashboard();
            }

            return const StudentDashboard();
          },
        );
      },
    );
  }
}
