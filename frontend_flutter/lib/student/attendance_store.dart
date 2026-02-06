import 'attendance_record.dart';

class AttendanceStore {
  static final List<AttendanceRecord> records = [];

  static AttendanceRecord? todayRecord() {
    final today = DateTime.now();
    try {
      return records.firstWhere(
        (r) =>
            r.date.year == today.year &&
            r.date.month == today.month &&
            r.date.day == today.day,
      );
    } catch (_) {
      return null;
    }
  }

  static void addTodayRecord(AttendanceRecord record) {
    records.removeWhere((r) =>
        r.date.year == record.date.year &&
        r.date.month == record.date.month &&
        r.date.day == record.date.day);
    records.add(record);
  }
}

