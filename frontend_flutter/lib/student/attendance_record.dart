import 'mark_attendance_screen.dart';

enum HostelMovementState {
  inside,
  temporarilyLeft,
  violationConfirmed,
}

class AttendanceRecord {
  final DateTime date;
  final AttendanceStatus status;
  HostelMovementState movementState;

  AttendanceRecord({
    required this.date,
    required this.status,
    HostelMovementState? movementState,
  }) : movementState = movementState ?? HostelMovementState.inside;
}
