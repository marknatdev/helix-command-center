import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum HelmetStatus { active, idle, sos, offline }

String statusLabel(HelmetStatus s) {
  switch (s) {
    case HelmetStatus.active:
      return 'Active';
    case HelmetStatus.idle:
      return 'Idle';
    case HelmetStatus.sos:
      return 'SOS';
    case HelmetStatus.offline:
      return 'Offline';
  }
}

Color statusColor(HelmetStatus s) {
  switch (s) {
    case HelmetStatus.sos:
      return AppColors.statusSos;
    case HelmetStatus.offline:
      return AppColors.statusOffline;
    case HelmetStatus.idle:
      return AppColors.statusWarn;
    case HelmetStatus.active:
      return AppColors.statusOk;
  }
}

class Helmet {
  final String id;
  final String worker;
  final String role;
  final String crew;
  HelmetStatus status;
  double battery; // 0-100
  double signal; // 0-100
  double heartRate;
  double impactG;
  double lat;
  double lng;
  double heading; // deg
  double speed; // m/s
  DateTime lastSeen;
  int sinceSos; // seconds

  Helmet({
    required this.id,
    required this.worker,
    required this.role,
    required this.crew,
    required this.status,
    required this.battery,
    required this.signal,
    required this.heartRate,
    required this.impactG,
    required this.lat,
    required this.lng,
    required this.heading,
    required this.speed,
    required this.lastSeen,
    this.sinceSos = 0,
  });

  String get initials =>
      worker.split(' ').map((p) => p.isEmpty ? '' : p[0]).join();
}

enum AlertKind { sos, impact, geofence, battery, offline, fall }

String alertKindLabel(AlertKind k) {
  switch (k) {
    case AlertKind.sos:
      return 'SOS';
    case AlertKind.impact:
      return 'Impact';
    case AlertKind.geofence:
      return 'Geofence';
    case AlertKind.battery:
      return 'Battery';
    case AlertKind.offline:
      return 'Offline';
    case AlertKind.fall:
      return 'Fall';
  }
}

Color alertKindColor(AlertKind k) {
  switch (k) {
    case AlertKind.sos:
    case AlertKind.impact:
      return AppColors.statusSos;
    case AlertKind.fall:
    case AlertKind.geofence:
    case AlertKind.battery:
      return AppColors.statusWarn;
    case AlertKind.offline:
      return AppColors.statusOffline;
  }
}

IconData alertKindIcon(AlertKind k) {
  switch (k) {
    case AlertKind.sos:
      return Icons.shield_outlined;
    case AlertKind.impact:
      return Icons.flash_on;
    case AlertKind.fall:
      return Icons.warning_amber_rounded;
    case AlertKind.geofence:
      return Icons.gps_fixed;
    case AlertKind.battery:
      return Icons.battery_alert;
    case AlertKind.offline:
      return Icons.wifi_off;
  }
}

class AlertEvent {
  final String id;
  final String helmetId;
  final String worker;
  final AlertKind kind;
  final String message;
  final DateTime ts;
  bool resolved;

  AlertEvent({
    required this.id,
    required this.helmetId,
    required this.worker,
    required this.kind,
    required this.message,
    required this.ts,
    this.resolved = false,
  });
}

String timeAgo(DateTime ts) {
  final diff = DateTime.now().difference(ts);
  final s = diff.inSeconds;
  if (s < 60) return '${s}s ago';
  final m = diff.inMinutes;
  if (m < 60) return '${m}m ago';
  final h = diff.inHours;
  return '${h}h ago';
}
