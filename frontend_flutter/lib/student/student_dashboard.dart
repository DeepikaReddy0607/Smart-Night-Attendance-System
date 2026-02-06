import 'package:flutter/material.dart';
import 'apply_permission_screen.dart';
import 'mark_attendance_screen.dart';
import 'attendance_history_screen.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
  children: [
    _btn(
      context,
      Icons.fingerprint,
      "Mark Attendance",
      const MarkAttendanceScreen(),
    ),

    const SizedBox(height: 20),

    _btn(
      context,
      Icons.assignment,
      "Apply Permission",
      const ApplyPermissionScreen(),
    ),

    const SizedBox(height: 20),
    _btn(
      context,
      Icons.history,
      "Attendance History",
      const AttendanceHistoryScreen(),
    ),
  ],
),

      ),
    );
  }

  Widget _btn(BuildContext ctx, IconData icon, String title, Widget screen) {
    return InkWell(
      onTap: () => Navigator.push(
          ctx, MaterialPageRoute(builder: (_) => screen)),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(icon, size: 30),
          const SizedBox(width: 20),
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w500))
        ]),
      ),
    );
  }
}
