import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_service.dart';
import '../state/helmet_feed.dart';
import '../theme/app_theme.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  static const _rates = [
    ('Fast', Duration(milliseconds: 500)),
    ('Normal', Duration(seconds: 2)),
    ('Slow', Duration(seconds: 5)),
  ];

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<HelmetFeed>();
    final auth = context.watch<AuthService>();

    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                const Icon(Icons.settings_outlined,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                const Text('Command center settings',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 16),
                  color: AppColors.mutedFg,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
              ]),
              const SizedBox(height: 4),
              const Text(
                'Adjust the live telemetry simulation.',
                style: TextStyle(fontSize: 11, color: AppColors.mutedFg),
              ),
              const SizedBox(height: 20),

              // Simulation speed
              const _SectionLabel('Simulation speed'),
              const SizedBox(height: 6),
              Row(
                children: [
                  for (final r in _rates) ...[
                    Expanded(
                      child: _SegButton(
                        label: r.$1,
                        active: feed.tickRate == r.$2,
                        onTap: () => feed.setTickRate(r.$2),
                      ),
                    ),
                    if (r != _rates.last) const SizedBox(width: 6),
                  ],
                ],
              ),
              const SizedBox(height: 18),

              // Pause / Resume
              _RowTile(
                icon: feed.paused ? Icons.play_arrow : Icons.pause,
                title: feed.paused ? 'Telemetry paused' : 'Live telemetry',
                subtitle: feed.paused
                    ? 'Simulation is frozen.'
                    : 'Helmet vitals update every tick.',
                trailing: Switch(
                  value: !feed.paused,
                  activeThumbColor: AppColors.statusOk,
                  onChanged: (v) => feed.setPaused(!v),
                ),
              ),
              const Divider(color: AppColors.border, height: 20),

              // Acknowledge all
              _ActionTile(
                icon: Icons.check_circle_outline,
                title: 'Acknowledge all alerts',
                subtitle: 'Mark every active incident as resolved.',
                onTap: () {
                  feed.acknowledgeAll();
                  _toast(context, 'All alerts acknowledged.');
                },
              ),
              const SizedBox(height: 8),
              _ActionTile(
                icon: Icons.restart_alt,
                title: 'Reset simulation',
                subtitle: 'Restore initial helmets and alerts.',
                destructive: true,
                onTap: () {
                  feed.resetSimulation();
                  _toast(context, 'Simulation reset.');
                },
              ),

              const SizedBox(height: 18),
              const _SectionLabel('Session'),
              const SizedBox(height: 6),
              _ActionTile(
                icon: Icons.logout,
                title: 'Sign out',
                subtitle: auth.user?.email ?? 'Signed in',
                destructive: true,
                onTap: () async {
                  final nav = Navigator.of(context);
                  await auth.signOut();
                  if (nav.mounted) nav.pop();
                },
              ),

              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.foreground,
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toast(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.popover,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          letterSpacing: 1.6,
          fontWeight: FontWeight.w600,
          color: AppColors.mutedFg,
        ));
  }
}

class _SegButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _SegButton(
      {required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.accent : Colors.transparent,
          border: Border.all(
              color: active ? AppColors.primary : AppColors.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                color: active ? AppColors.foreground : AppColors.mutedFg,
                fontWeight: FontWeight.w500)),
      ),
    );
  }
}

class _RowTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  const _RowTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: AppColors.mutedFg),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.mutedFg)),
          ],
        ),
      ),
      trailing,
    ]);
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });
  @override
  Widget build(BuildContext context) {
    final c = destructive ? AppColors.statusSos : AppColors.foreground;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(children: [
          Icon(icon, size: 16, color: c),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: c)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.mutedFg)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              size: 16, color: AppColors.mutedFg),
        ]),
      ),
    );
  }
}
