enum GeoFenceStatus {
  insideHostel,
  outsideHostel,
  unknown,
}

class GeoFenceService {
  static GeoFenceStatus currentStatus = GeoFenceStatus.insideHostel;

  static bool canMarkAttendance() {
    return currentStatus == GeoFenceStatus.insideHostel;
  }

  static bool hasLeftHostel() {
    return currentStatus == GeoFenceStatus.outsideHostel;
  }
}
