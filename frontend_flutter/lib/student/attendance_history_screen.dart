import 'package:flutter/material.dart';
import 'attendance_store.dart';
import 'attendance_record.dart';
import 'mark_attendance_screen.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  Color _statusColor(AttendanceRecord r) {
  if (r.movementState == HostelMovementState.violationConfirmed) {
    return Colors.red.shade200;
  }

  if (r.movementState == HostelMovementState.temporarilyLeft) {
    return Colors.yellow.shade200;
  }

  switch (r.status) {
    case AttendanceStatus.onTime:
      return Colors.green.shade100;
    case AttendanceStatus.late:
      return Colors.orange.shade100;
    case AttendanceStatus.absent:
      return Colors.grey.shade300;
    default:
      return Colors.white;
  }
}
  
  IconData _statusIcon(AttendanceRecord r) {
  if (r.movementState == HostelMovementState.violationConfirmed) {
    return Icons.report;
  }

  if (r.movementState == HostelMovementState.temporarilyLeft) {
    return Icons.exit_to_app;
  }

  switch (r.status) {
    case AttendanceStatus.onTime:
      return Icons.check_circle;
    case AttendanceStatus.late:
      return Icons.warning;
    case AttendanceStatus.absent:
      return Icons.block;
    default:
      return Icons.help;
  }
}

  String _statusText(AttendanceRecord r) {
  if (r.movementState == HostelMovementState.violationConfirmed) {
    return "Violation: Marked & Left Hostel";
  }

  if (r.movementState == HostelMovementState.temporarilyLeft) {
    return "Marked & Left (Temporary)";
  }

  switch (r.status) {
    case AttendanceStatus.onTime:
      return "On Time";
    case AttendanceStatus.late:
      return "Late";
    case AttendanceStatus.absent:
      return "Absent";
    default:
      return "Not Marked";
  }
}

  @override
  Widget build(BuildContext context) {
    final records = AttendanceStore.records;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance History"),
        centerTitle: true,
      ),
      body: records.isEmpty
          ? const Center(
              child: Text("No attendance records available"),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _statusColor(record),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _statusIcon(record),
                        size: 30,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${record.date.day}-${record.date.month}-${record.date.year}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _statusText(record),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
