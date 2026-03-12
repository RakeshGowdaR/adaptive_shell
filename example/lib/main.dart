import 'package:adaptive_shell/adaptive_shell.dart';
import 'package:flutter/material.dart';

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
// AdaptiveMasterDetail<T> — Zero boilerplate (~30 lines)
// No manual state, no navigation logic, no layout checks.
// ══════════════════════════════════════════════════════════════

class ZeroBoilerplateExample extends StatefulWidget {
  const ZeroBoilerplateExample({super.key});

  @override
  State<ZeroBoilerplateExample> createState() => _ZeroBoilerplateExampleState();
}

class _ZeroBoilerplateExampleState extends State<ZeroBoilerplateExample> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AdaptiveMasterDetail<Patient>(
      items: _patients,
      destinations: _destinations,
      selectedNavIndex: _navIndex,
      onNavSelected: (i) => setState(() => _navIndex = i),
      breakpoints: AdaptiveBreakpoints.tabletFirst,

      // Provide two builders — everything else is handled.
      itemBuilder: (context, patient, selected) =>
          PatientTile(patient: patient, selected: selected),
      detailBuilder: (context, patient) => PatientDetail(patient: patient),

      // Optional:
      itemKey: (p) => p.id,
      initialSelection: (items) => items.first,
      detailAppBarTitle: (p) => p.name,
      masterHeader: const SearchHeader(),
      emptyDetailPlaceholder: const EmptyPlaceholder(),
    );
  }
}

// ─── Shared widgets ───

class SearchHeader extends StatelessWidget {
  const SearchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
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
    );
  }
}

class EmptyPlaceholder extends StatelessWidget {
  const EmptyPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.touch_app_outlined, size: 48, color: Colors.grey.shade400),
      const SizedBox(height: 12),
      Text('Select a patient',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
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
        leading: CircleAvatar(
          backgroundColor: patient.color.withAlpha(25),
          foregroundColor: patient.color,
          child: Text('${patient.priority}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        title: Text(patient.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text('${patient.gender} | ${patient.age} | ${patient.bed}',
                    style: Theme.of(context).textTheme.bodySmall),
              ])),
        ]),
        const SizedBox(height: 24),
        _section(
            context,
            'VITALS',
            Icons.monitor_heart,
            patient.color,
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _V(l: 'HR', v: '72', u: 'bpm'),
                _V(l: 'BP', v: '120/80', u: 'mmHg'),
                _V(l: 'Temp', v: '98.6', u: 'F'),
                _V(l: 'SpO2', v: '98', u: '%')
              ],
            )),
        const SizedBox(height: 12),
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
  Widget build(BuildContext context) => Column(children: [
        Text(l,
            style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.bold)),
        Text(v,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        Text(u, style: TextStyle(fontSize: 9, color: Colors.grey.shade400)),
      ]);
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
