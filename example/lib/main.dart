import 'dart:math' show min;

import 'package:adaptive_shell/adaptive_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adaptive Shell Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorSchemeSeed: const Color(0xFFE11D48), useMaterial3: true),
      home: const ZeroBoilerplateExample(),
    );
  }
}

// ─── Data ───

class Patient {
  const Patient(
      {required this.id,
      required this.name,
      required this.gender,
      required this.age,
      required this.bed,
      required this.priority,
      required this.color});

  final int id;
  final String name, gender, age, bed;
  final int priority;
  final Color color;
}

const _patients = [
  Patient(
      id: 1,
      name: 'Kapil Meghwal',
      gender: 'M',
      age: '24y',
      bed: 'ICU-204',
      priority: 8,
      color: Color(0xFFE11D48)),
  Patient(
      id: 2,
      name: 'Shreya Choudhary',
      gender: 'F',
      age: '24y',
      bed: 'W3-112',
      priority: 1,
      color: Color(0xFFEA580C)),
  Patient(
      id: 3,
      name: 'Baby of Chitra K.',
      gender: 'M',
      age: '11M',
      bed: 'NICU-08',
      priority: 7,
      color: Color(0xFFCA8A04)),
  Patient(
      id: 4,
      name: 'Ayush Sharma',
      gender: 'M',
      age: '24y',
      bed: 'W1-305',
      priority: 2,
      color: Color(0xFF059669)),
  Patient(
      id: 5,
      name: 'Ramgopal Rathore',
      gender: 'M',
      age: '46y',
      bed: 'ICU-211',
      priority: 6,
      color: Color(0xFF2563EB)),
  Patient(
      id: 6,
      name: 'Deepika Rathore',
      gender: 'F',
      age: '24y',
      bed: 'W2-118',
      priority: 4,
      color: Color(0xFF7C3AED)),
];

const _destinations = [
  AdaptiveDestination(
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      label: 'Patients'),
  AdaptiveDestination(
      icon: Icons.task_outlined,
      selectedIcon: Icons.task,
      label: 'Tasks',
      badge: 3),
  AdaptiveDestination(
      icon: Icons.chat_outlined,
      selectedIcon: Icons.chat,
      label: 'Chat',
      badge: 5),
  AdaptiveDestination(
      icon: Icons.monitor_heart_outlined,
      selectedIcon: Icons.monitor_heart,
      label: 'Vitals'),
  AdaptiveDestination(icon: Icons.more_horiz, label: 'More'),
];

// ══════════════════════════════════════════════════════════════
// AdaptiveMasterDetail<T> — Zero-boilerplate example
//
// Showcases ALL v1.1.0 features:
//  • onLayoutModeChanged  — snackbar on every layout transition
//  • debugShowLayoutMode  — toggleable dev overlay (top-right)
//  • context.adaptivePadding / adaptiveFontSize / adaptiveSpacing
//
// NEW in v1.1.0 (toggled via the ⚙ FAB):
//  📏 AutoScale            — autoScale + autoScaleDesignWidth
//  💾 State Persistence    — persistState + stateKey
//  ✨ Hero Animations       — enableHeroAnimations + transitionCurve
//  📍 Collapsible Rail     — railCollapsible + railCollapseOnMedium
//  ⌨️  Keyboard Shortcuts   — keyboardShortcuts (Ctrl+1…5)
//
// NEW context extensions demonstrated inline:
//  • context.layoutMode   — displayed as a chip in the search header
//  • context.adaptiveColumns  — drives vitals-grid columns
//  • context.adaptiveValue<T> — items-per-row in vitals grid
// ══════════════════════════════════════════════════════════════

class ZeroBoilerplateExample extends StatefulWidget {
  const ZeroBoilerplateExample({super.key});

  @override
  State<ZeroBoilerplateExample> createState() => _ZeroBoilerplateExampleState();
}

class _ZeroBoilerplateExampleState extends State<ZeroBoilerplateExample> {
  int _navIndex = 0;

  // ── Feature toggles (all v1.1.0) ─────────────────────────────
  bool _showDebugOverlay = false;
  bool _autoScale = false;
  bool _persistState = false;
  bool _heroAnimations = false;
  bool _railCollapsible = true;
  bool _railCollapseOnMedium = false;

  // ─────────────────────────────────────────────────────────────

  void _onLayoutModeChanged(LayoutMode oldMode, LayoutMode newMode) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Layout: ${oldMode.name} → ${newMode.name}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Opens the feature-toggle sheet.
  void _openFeatureToggles() {
    showModalBottomSheet<void>(
      context: context,
      // Allow the sheet to grow beyond the default 50 % cap so all
      // six toggles fit without overflowing on compact screens.
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FeatureToggleSheet(
        showDebugOverlay: _showDebugOverlay,
        autoScale: _autoScale,
        persistState: _persistState,
        heroAnimations: _heroAnimations,
        railCollapsible: _railCollapsible,
        railCollapseOnMedium: _railCollapseOnMedium,
        onChanged: ({
          required bool debugOverlay,
          required bool autoScale,
          required bool persistState,
          required bool heroAnimations,
          required bool railCollapsible,
          required bool railCollapseOnMedium,
        }) {
          setState(() {
            _showDebugOverlay = debugOverlay;
            _autoScale = autoScale;
            _persistState = persistState;
            _heroAnimations = heroAnimations;
            _railCollapsible = railCollapsible;
            _railCollapseOnMedium = railCollapseOnMedium;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ⚙ FAB opens the feature-toggle sheet.
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'settings',
        tooltip: 'Feature toggles',
        onPressed: _openFeatureToggles,
        child: const Icon(Icons.tune),
      ),
      body: SafeArea(
        child: AdaptiveMasterDetail<Patient>(
          items: _patients,
          destinations: _destinations,
          selectedNavIndex: _navIndex,
          onNavSelected: (i) => setState(() => _navIndex = i),
          breakpoints: AdaptiveBreakpoints.tabletFirst,

          // ── Existing v1.1.0 ──────────────────────────────────────
          onLayoutModeChanged: _onLayoutModeChanged,
          debugShowLayoutMode: _showDebugOverlay,

          // ── 📏 AutoScale (new v1.1.0) ────────────────────────────
          // Renders the layout at 360 dp and proportionally scales it
          // to fill the actual screen — mobile design "just works" on
          // any device.  Toggle via the ⚙ FAB.
          autoScale: _autoScale,

          // ── 💾 State Persistence (new v1.1.0) ────────────────────
          // Preserves scroll positions and widget state when the
          // device rotates or the layout mode switches.
          persistState: _persistState,
          stateKey: 'patient_shell',

          // ── ✨ Animated Transitions (new v1.1.0) ──────────────────
          // enableHeroAnimations replaces the cross-fade with a
          // slide + fade when selecting a patient — tap a tile to see.
          // transitionCurve controls the easing.
          enableHeroAnimations: _heroAnimations,
          transitionCurve: _heroAnimations ? Curves.easeInOutCubic : null,

          // ── 📍 Collapsible Rail (new v1.1.0) ─────────────────────
          // A chevron button appears above the rail so users can
          // collapse it to icon-only mode. railCollapseOnMedium
          // auto-collapses on tablet breakpoint.
          railCollapsible: _railCollapsible,
          railCollapseOnMedium: _railCollapseOnMedium,

          // ── ⌨️ Keyboard Shortcuts (new v1.1.0) ───────────────────
          // Ctrl+1…5 jump directly to each nav destination on
          // tablet/desktop. Inactive on compact (mobile) layout.
          keyboardShortcuts: {
            SingleActivator(LogicalKeyboardKey.digit1, control: true): 0,
            SingleActivator(LogicalKeyboardKey.digit2, control: true): 1,
            SingleActivator(LogicalKeyboardKey.digit3, control: true): 2,
            SingleActivator(LogicalKeyboardKey.digit4, control: true): 3,
            SingleActivator(LogicalKeyboardKey.digit5, control: true): 4,
          },

          itemBuilder: (context, patient, selected) =>
              PatientTile(patient: patient, selected: selected),
          detailBuilder: (context, patient) => PatientDetail(patient: patient),

          itemKey: (p) => p.id,
          initialSelection: (items) => items.first,
          detailAppBarTitle: (p) => p.name,
          masterHeader: const SearchHeader(),
          emptyDetailPlaceholder: const EmptyPlaceholder(),
        ),
      ),
    );
  }
}

// ─── Feature-toggle bottom sheet ─────────────────────────────────────────────

typedef _OnFeaturesChanged = void Function({
  required bool debugOverlay,
  required bool autoScale,
  required bool persistState,
  required bool heroAnimations,
  required bool railCollapsible,
  required bool railCollapseOnMedium,
});

class _FeatureToggleSheet extends StatefulWidget {
  const _FeatureToggleSheet({
    required this.showDebugOverlay,
    required this.autoScale,
    required this.persistState,
    required this.heroAnimations,
    required this.railCollapsible,
    required this.railCollapseOnMedium,
    required this.onChanged,
  });

  final bool showDebugOverlay, autoScale, persistState, heroAnimations;
  final bool railCollapsible, railCollapseOnMedium;
  final _OnFeaturesChanged onChanged;

  @override
  State<_FeatureToggleSheet> createState() => _FeatureToggleSheetState();
}

class _FeatureToggleSheetState extends State<_FeatureToggleSheet> {
  late bool _debug, _auto, _persist, _hero, _railCollapsible, _railCollapseOnMedium;

  @override
  void initState() {
    super.initState();
    _debug = widget.showDebugOverlay;
    _auto = widget.autoScale;
    _persist = widget.persistState;
    _hero = widget.heroAnimations;
    _railCollapsible = widget.railCollapsible;
    _railCollapseOnMedium = widget.railCollapseOnMedium;
  }

  void _notify() => widget.onChanged(
        debugOverlay: _debug,
        autoScale: _auto,
        persistState: _persist,
        heroAnimations: _hero,
        railCollapsible: _railCollapsible,
        railCollapseOnMedium: _railCollapseOnMedium,
      );

  @override
  Widget build(BuildContext context) {
    // Cap the sheet at 85 % of screen height so it never covers the whole
    // screen, but can grow well past the old 50 % default.  The ListView
    // makes the toggle list scrollable on very small screens or landscape.
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 32 + bottomInset),
        child: ListView(
          shrinkWrap: true,
          children: [
            // ── Handle ────────────────────────────────────────────
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text('Feature Toggles (v1.1.0)',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Toggle live to see each feature in action.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey.shade500)),
            const Divider(height: 24),
            // ── Toggles ───────────────────────────────────────────
            _Toggle(
              icon: Icons.bug_report_outlined,
              color: Colors.blueGrey,
              title: 'Debug Overlay',
              subtitle: 'Mode, breakpoints & scale factor — top-right corner',
              value: _debug,
              onChanged: (v) {
                setState(() => _debug = v);
                _notify();
              },
            ),
            _Toggle(
              icon: Icons.zoom_out_map,
              color: Colors.indigo,
              title: '📏 AutoScale',
              subtitle:
                  'Renders at 360 dp, scales to fill screen — resize to see',
              value: _auto,
              onChanged: (v) {
                setState(() => _auto = v);
                _notify();
              },
            ),
            _Toggle(
              icon: Icons.save_outlined,
              color: Colors.teal,
              title: '💾 Persist State',
              subtitle:
                  'Scroll position survives layout transitions — resize to test',
              value: _persist,
              onChanged: (v) {
                setState(() => _persist = v);
                _notify();
              },
            ),
            _Toggle(
              icon: Icons.animation,
              color: Colors.orange,
              title: '✨ Hero Animations',
              subtitle:
                  'Slide + fade when selecting a patient — tap a tile to see',
              value: _hero,
              onChanged: (v) {
                setState(() => _hero = v);
                _notify();
              },
            ),
            _Toggle(
              icon: Icons.menu_open,
              color: Colors.purple,
              title: '📍 Collapsible Rail',
              subtitle:
                  'Chevron button collapses nav rail to icon-only (tablet+)',
              value: _railCollapsible,
              onChanged: (v) {
                setState(() => _railCollapsible = v);
                _notify();
              },
            ),
            _Toggle(
              icon: Icons.tablet_outlined,
              color: Colors.deepPurple,
              title: '📍 Auto-collapse on Tablet',
              subtitle:
                  'Rail collapses automatically when entering medium mode',
              value: _railCollapseOnMedium,
              onChanged: (v) {
                setState(() => _railCollapseOnMedium = v);
                _notify();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color color;
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: color.withAlpha(25), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: color),
      ),
      title: Text(title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      value: value,
      onChanged: onChanged,
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

/// Search bar header — demonstrates [context.layoutMode] and
/// [context.adaptiveColumns] (new v1.1.0 extensions).
class SearchHeader extends StatelessWidget {
  const SearchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // NEW v1.1.0: context.layoutMode — alias for screenType, usable in switch.
    final mode = context.layoutMode;
    final modeLabel = switch (mode) {
      LayoutMode.compact => '📱 Compact',
      LayoutMode.medium => '📟 Medium',
      LayoutMode.expanded => '🖥 Expanded',
    };

    return Padding(
      // Existing v1.1.0: adaptivePadding scales 12 → 16 → 20.
      padding: context.adaptivePadding(compact: 12, medium: 16, expanded: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search patient...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withAlpha(77),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
          const SizedBox(height: 6),
          // NEW v1.1.0: context.layoutMode chip + context.adaptiveColumns badge.
          Row(
            children: [
              // Shows current LayoutMode via context.layoutMode.
              Chip(
                padding: EdgeInsets.zero,
                labelPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                visualDensity: VisualDensity.compact,
                label: Text(modeLabel,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              // Shows adaptiveColumns value — 1 / 2 / 3 per screen size.
              Chip(
                padding: EdgeInsets.zero,
                labelPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                visualDensity: VisualDensity.compact,
                backgroundColor: Colors.grey.shade100,
                label: Text(
                    '${context.adaptiveColumns} col${context.adaptiveColumns > 1 ? 's' : ''}',
                    style:
                        TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmptyPlaceholder extends StatelessWidget {
  const EmptyPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.touch_app_outlined,
          // Existing v1.1.0: context.adaptiveWidth scales icon size.
          size: context.adaptiveWidth(48),
          color: Colors.grey.shade400),
      const SizedBox(height: 12),
      Text('Select a patient',
          style: TextStyle(
              color: Colors.grey.shade500,
              // Existing v1.1.0: adaptiveFontSize scales 16 → 17.6 → 19.2.
              fontSize: context.adaptiveFontSize(16))),
    ]);
  }
}

class PatientTile extends StatelessWidget {
  const PatientTile({super.key, required this.patient, this.selected = false});

  final Patient patient;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: selected ? patient.color.withAlpha(20) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: selected
            ? BorderSide(color: patient.color.withAlpha(77))
            : BorderSide.none,
      ),
      child: ListTile(
        // Existing v1.1.0: adaptive content padding.
        contentPadding: context
            .adaptivePadding(compact: 8, medium: 12, expanded: 16)
            .copyWith(top: 0, bottom: 0),
        leading: CircleAvatar(
          backgroundColor: patient.color.withAlpha(25),
          foregroundColor: patient.color,
          child: Text('${patient.priority}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        title: Text(patient.name,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                // Existing v1.1.0: font scales up on larger screens.
                fontSize: context.adaptiveFontSize(14))),
        subtitle: Text('${patient.gender} | ${patient.age} | ${patient.bed}'),
        trailing: selected
            ? Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                    color: patient.color,
                    borderRadius: BorderRadius.circular(2)))
            : const Icon(Icons.chevron_right, size: 20),
      ),
    );
  }
}

class PatientDetail extends StatelessWidget {
  const PatientDetail({super.key, required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    // Existing v1.1.0: adaptive padding 16 → 24 → 32.
    return SingleChildScrollView(
      padding: context.adaptivePadding(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header ──
        Row(children: [
          CircleAvatar(
              radius: 24,
              backgroundColor: patient.color.withAlpha(25),
              foregroundColor: patient.color,
              child: Text(
                  patient.name.split(' ').map((w) => w[0]).take(2).join(),
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(patient.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        // Existing v1.1.0: title scales responsively.
                        fontSize: context.adaptiveFontSize(20))),
                Text('${patient.gender} | ${patient.age} | ${patient.bed}',
                    style: Theme.of(context).textTheme.bodySmall),
              ])),
        ]),

        // Existing v1.1.0: adaptive vertical spacing.
        SizedBox(height: context.adaptiveSpacing(24)),

        // ── Vitals card — demonstrates context.adaptiveValue ─────────────
        _section(context, 'VITALS', Icons.monitor_heart, patient.color,
            // NEW v1.1.0: context.adaptiveValue<int> — type-safe per-breakpoint
            // value. Shows 2 vitals per row on compact, 4 on medium/expanded.
            Builder(builder: (ctx) {
          final perRow =
              ctx.adaptiveValue<int>(compact: 2, medium: 4, expanded: 4);
          const vitals = [
            _V(l: 'HR', v: '72', u: 'bpm'),
            _V(l: 'BP', v: '120/80', u: 'mmHg'),
            _V(l: 'Temp', v: '98.6', u: 'F'),
            _V(l: 'SpO2', v: '98', u: '%'),
          ];
          return Column(
            children: [
              for (int i = 0; i < vitals.length; i += perRow)
                Padding(
                  padding: EdgeInsets.only(
                      bottom: i + perRow < vitals.length ? 8 : 0),
                  child: Row(
                    children: vitals
                        .sublist(i, min(i + perRow, vitals.length))
                        .map((v) => Expanded(child: v))
                        .toList(),
                  ),
                ),
            ],
          );
        })),

        SizedBox(height: context.adaptiveSpacing(12)),

        // ── Tasks card ───────────────────────────────────────────────────
        _section(
            context,
            'TASKS',
            Icons.task,
            Colors.orange,
            const Column(children: [
              _T(t: 'Collect CBC sample', d: '19 Aug', u: true),
              _T(t: 'Change sheets', d: '09 Aug', u: false),
            ])),
      ]),
    );
  }

  Widget _section(
      BuildContext ctx, String title, IconData icon, Color c, Widget child) {
    return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey.shade200)),
        child: Padding(
            padding: const EdgeInsets.all(14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(icon, size: 16, color: c),
                const SizedBox(width: 6),
                Text(title,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.5))
              ]),
              const SizedBox(height: 10),
              child,
            ])));
  }
}

class _V extends StatelessWidget {
  const _V({required this.l, required this.v, required this.u});

  final String l, v, u;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(l,
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.bold)),
          Text(v,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          Text(u, style: TextStyle(fontSize: 9, color: Colors.grey.shade400)),
        ],
      );
}

class _T extends StatelessWidget {
  const _T({required this.t, required this.d, required this.u});

  final String t, d;
  final bool u;

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Container(
            width: 4,
            height: 28,
            decoration: BoxDecoration(
                color: u ? Colors.orange : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          Text('Due: $d',
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.red.shade400,
                  fontWeight: FontWeight.w600)),
        ])),
      ]));
}
