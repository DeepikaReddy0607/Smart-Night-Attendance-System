import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'student_permission.dart';
import 'attendance_store.dart';
import 'attendance_record.dart';
import 'geofence_service.dart';

enum AttendanceStatus { notMarked, onTime, late, absent }

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  AttendanceStatus status = AttendanceStatus.notMarked;
  bool isSubmitting = false;

  bool isAttendanceWindowOpen() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 21, 30);
    final end = DateTime(now.year, now.month, now.day, 23, 59);

    if (StudentPermission.activePermission == PermissionType.library) {
      return now.isAfter(start) || now.hour < 1;
    }
    return now.isAfter(start) && now.isBefore(end);
  }

  AttendanceStatus calculateStatus() {
    final now = DateTime.now();

    if (StudentPermission.isNonLocalActive(now)) {
      return AttendanceStatus.absent;
    }

    final cutoff =
        StudentPermission.activePermission == PermissionType.library
            ? DateTime(now.year, now.month, now.day + 1, 0, 0)
            : DateTime(now.year, now.month, now.day, 22, 0);

    return now.isBefore(cutoff)
        ? AttendanceStatus.onTime
        : AttendanceStatus.late;
  }

  void checkForViolation() {
    final record = AttendanceStore.todayRecord();
    if (record == null) return;

    if (GeoFenceService.hasLeftHostel() &&
        record.movementState == HostelMovementState.inside) {
      record.movementState = HostelMovementState.temporarilyLeft;
    }

    final now = DateTime.now();

    final cutoff =
        StudentPermission.activePermission == PermissionType.library
            ? DateTime(now.year, now.month, now.day + 1, 0, 0)
            : DateTime(now.year, now.month, now.day, 22, 0);

    if (record.movementState ==
            HostelMovementState.temporarilyLeft &&
        now.isAfter(cutoff)) {
      record.movementState = HostelMovementState.violationConfirmed;
      debugPrint(
          "WARDEN ALERT: Student marked attendance and left hostel.");
    }
  }
  Future<void> _markAttendance(BuildContext context) async {
  if (isSubmitting) return;

  setState(() => isSubmitting = true);

  final LocalAuthentication auth = LocalAuthentication();

  bool biometricSuccess = false;

  try {
    biometricSuccess = await auth.authenticate(
      localizedReason: 'Authenticate to mark attendance',
      options: const AuthenticationOptions(
        biometricOnly: true,
      ),
    );
  } catch (e) {
    biometricSuccess = false;
  }

  if (!biometricSuccess) {
    setState(() => isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Biometric authentication failed")),
    );
    return;
  }

  final newStatus = calculateStatus();

  final record = AttendanceRecord(
    date: DateTime.now(),
    status: newStatus,
  );

  AttendanceStore.addTodayRecord(record);

  setState(() {
    status = newStatus;
    StudentPermission.lastAttendanceDate = DateTime.now();
    isSubmitting = false;
  });
}

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final alreadyMarked = StudentPermission.lastAttendanceDate != null &&
        DateUtils.isSameDay(StudentPermission.lastAttendanceDate, now);

    final todayRecord = AttendanceStore.todayRecord();

    checkForViolation(); // controlled call

    return Scaffold(
      appBar: AppBar(title: const Text("Mark Attendance")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fingerprint, size: 80),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: alreadyMarked ||
                        !isAttendanceWindowOpen() ||
                        !GeoFenceService.canMarkAttendance() ||
                        isSubmitting
                    ? null
                    : () => _markAttendance(context),
                child: isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text(
                        "Mark Attendance",
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),

            const SizedBox(height: 30),

            Text(
              todayRecord == null
                  ? "Attendance not marked"
                  : todayRecord.movementState ==
                          HostelMovementState.violationConfirmed
                      ? "Violation: Marked & Left Hostel"
                      : todayRecord.movementState ==
                              HostelMovementState.temporarilyLeft
                          ? "Marked & Left (Outside Hostel)"
                          : status == AttendanceStatus.onTime
                              ? "Attendance Marked (On Time)"
                              : status == AttendanceStatus.late
                                  ? "Attendance Marked (Late)"
                                  : "Absent (Non-Local Outing)",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
