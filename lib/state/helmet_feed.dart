import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

import '../data/helmet_data.dart';
import '../models/helmet.dart';

/// Simulates a live websocket feed of helmet telemetry.
class HelmetFeed extends ChangeNotifier {
  List<Helmet> helmets = buildInitialHelmets();
  List<AlertEvent> alerts = buildInitialAlerts();
  final _rand = Random();
  Timer? _telemetry;
  Timer? _firstAlert;
  int _tick = 0;

  // Settings
  Duration _tickRate = const Duration(seconds: 2);
  bool _paused = false;

  Duration get tickRate => _tickRate;
  bool get paused => _paused;

  HelmetFeed() {
    _startTimer();
    _firstAlert = Timer(const Duration(seconds: 9), () {
      alerts.insert(
        0,
        AlertEvent(
          id: 'sim-${DateTime.now().millisecondsSinceEpoch}',
          helmetId: 'HLX-0267',
          worker: 'K. Haruto',
          kind: AlertKind.geofence,
          message: 'Approaching fall-risk zone · Tower 2 edge',
          ts: DateTime.now(),
        ),
      );
      notifyListeners();
    });
  }

  void _startTimer() {
    _telemetry?.cancel();
    _telemetry = Timer.periodic(_tickRate, (_) {
      if (!_paused) _step();
    });
  }

  void setTickRate(Duration d) {
    _tickRate = d;
    _startTimer();
    notifyListeners();
  }

  void setPaused(bool v) {
    _paused = v;
    notifyListeners();
  }

  void acknowledgeAll() {
    for (final a in alerts) {
      a.resolved = true;
    }
    notifyListeners();
  }

  void resetSimulation() {
    helmets = buildInitialHelmets();
    alerts = buildInitialAlerts();
    _tick = 0;
    notifyListeners();
  }

  void _step() {
    _tick += 1;
    for (final h in helmets) {
      if (h.status == HelmetStatus.offline) continue;

      if (h.status == HelmetStatus.sos) {
        h.heartRate = _clamp(h.heartRate + (_rand.nextDouble() - 0.5) * 6, 115, 145);
        h.sinceSos += 2;
        h.lastSeen = DateTime.now();
        continue;
      }

      final headingDrift = (_rand.nextDouble() - 0.5) * 30;
      h.heading = (h.heading + headingDrift + 360) % 360;
      final rad = h.heading * pi / 180;
      final step = (h.speed > 0 ? h.speed : 0.6) * 0.0000135;
      h.lat += cos(rad) * step;
      h.lng += sin(rad) * step;

      h.heartRate = _clamp(
        h.heartRate + (_rand.nextDouble() - 0.5) * 4,
        62,
        115,
      ).roundToDouble();
      if (_tick % 30 == 0) {
        h.battery = max(0, h.battery - 1);
      }
      h.signal = _clamp(h.signal + (_rand.nextDouble() - 0.5) * 6, 40, 100)
          .roundToDouble();
      h.lastSeen = DateTime.now();
    }
    notifyListeners();
  }

  double _clamp(double v, double a, double b) => v < a ? a : (v > b ? b : v);

  void acknowledge(String alertId) {
    final idx = alerts.indexWhere((x) => x.id == alertId);
    if (idx == -1) return;
    alerts[idx].resolved = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _telemetry?.cancel();
    _firstAlert?.cancel();
    super.dispose();
  }
}
