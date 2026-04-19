import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/auth_gate.dart';
import 'auth/auth_service.dart';
import 'firebase_options.dart';
import 'models/helmet.dart';
import 'state/helmet_feed.dart';
import 'theme/app_theme.dart';
import 'views/fleet_view.dart';
import 'views/incidents_view.dart';
import 'views/live_view.dart';
import 'views/reports_view.dart';
import 'views/zones_view.dart';
import 'widgets/command_header.dart';
import 'widgets/settings_dialog.dart';

/// Site name shown in the header and map HUD.
const String kSiteName = 'PIER-27';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF121418),
        body: Center(
          child: Text('Init error: $e',
              style: const TextStyle(color: Colors.red, fontSize: 14)),
        ),
      ),
    ));
    return;
  }
  runApp(const HelixApp());
}

class HelixApp extends StatelessWidget {
  const HelixApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => HelmetFeed()),
      ],
      child: MaterialApp(
        title: 'HELIX · Smart Helmet Command Center',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const AuthGate(child: CommandCenterPage()),
      ),
    );
  }
}

class CommandCenterPage extends StatefulWidget {
  const CommandCenterPage({super.key});
  @override
  State<CommandCenterPage> createState() => _CommandCenterPageState();
}

class _CommandCenterPageState extends State<CommandCenterPage> {
  String? _selectedId = 'HLX-0187';
  String _filter = 'all';
  String _tab = 'Live';

  void _openSettings() {
    final feed = context.read<HelmetFeed>();
    final auth = context.read<AuthService>();
    showDialog(
      context: context,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: feed),
          ChangeNotifierProvider.value(value: auth),
        ],
        child: const SettingsDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<HelmetFeed>();
    final helmets = feed.helmets;
    final selected = _selectedId == null
        ? null
        : helmets.cast<Helmet?>().firstWhere(
              (h) => h!.id == _selectedId,
              orElse: () => null,
            );
    final sosCount =
        helmets.where((h) => h.status == HelmetStatus.sos).length;

    return Scaffold(
      body: Column(children: [
        CommandHeader(
          siteName: kSiteName,
          sosCount: sosCount,
          activeTab: _tab,
          onTabChange: (t) => setState(() => _tab = t),
          onOpenSettings: _openSettings,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _buildTab(feed, helmets, selected),
          ),
        ),
      ]),
    );
  }

  Widget _buildTab(HelmetFeed feed, List<Helmet> helmets, Helmet? selected) {
    switch (_tab) {
      case 'Fleet':
        return FleetView(
          helmets: helmets,
          selectedId: _selectedId,
          selected: selected,
          onSelect: (id) => setState(() => _selectedId = id),
          filter: _filter,
          onFilterChange: (f) => setState(() => _filter = f),
          onClose: () => setState(() => _selectedId = null),
        );
      case 'Incidents':
        return IncidentsView(
          feed: feed,
          onSelect: (id) => setState(() {
            _selectedId = id;
            _tab = 'Live';
          }),
        );
      case 'Zones':
        return ZonesView(
          helmets: helmets,
          selectedId: _selectedId,
          onSelect: (id) => setState(() => _selectedId = id),
        );
      case 'Reports':
        return ReportsView(helmets: helmets, alerts: feed.alerts);
      case 'Live':
      default:
        return LiveView(
          feed: feed,
          helmets: helmets,
          selectedId: _selectedId,
          selected: selected,
          onSelect: (id) => setState(() => _selectedId = id),
          filter: _filter,
          onFilterChange: (f) => setState(() => _filter = f),
          onClose: () => setState(() => _selectedId = null),
        );
    }
  }
}
