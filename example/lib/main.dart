import 'package:adaptive_shell/adaptive_shell.dart';
import 'package:adaptive_shell/src/adaptive_destination.dart';
import 'package:adaptive_shell/src/breakpoints.dart';
import 'package:adaptive_shell/src/layout_mode.dart';
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
        colorSchemeSeed: const Color(0xFFE11D48),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// ─── Sample data ───

class Patient {
  const Patient({
    required this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.bed,
    required this.priority,
    required this.color,
  });

  final int id;
  final String name;
  final String gender;
  final String age;
  final String bed;
  final int priority;
  final Color color;
}

const _patients = [
  Patient(id: 1, name: 'Kapil Meghwal', gender: 'M', age: '24y', bed: 'ICU-204', priority: 8, color: Color(0xFFE11D48)),
  Patient(id: 2, name: 'Shreya Choudhary', gender: 'F', age: '24y', bed: 'W3-112', priority: 1, color: Color(0xFFEA580C)),
  Patient(id: 3, name: 'Baby of Chitra K.', gender: 'M', age: '11M', bed: 'NICU-08', priority: 7, color: Color(0xFFCA8A04)),
  Patient(id: 4, name: 'Ayush Sharma', gender: 'M', age: '24y', bed: 'W1-305', priority: 2, color: Color(0xFF059669)),
  Patient(id: 5, name: 'Ramgopal Rathore', gender: 'M', age: '46y', bed: 'ICU-211', priority: 6, color: Color(0xFF2563EB)),
  Patient(id: 6, name: 'Deepika Rathore', gender: 'F', age: '24y', bed: 'W2-118', priority: 4, color: Color(0xFF7C3AED)),
];

// ─── Home screen ───

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  Patient? _selectedPatient;

  void _handlePatientTap(Patient patient) {
    final mode = AdaptiveShell.of(context);

    if (mode == LayoutMode.compact) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: Text(patient.name)),
            body: _PatientDetail(patient: patient),
          ),
        ),
      );
    } else {
      setState(() => _selectedPatient = patient);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveShell(
      destinations: const [
        AdaptiveDestination(
          icon: Icons.people_outline,
          selectedIcon: Icons.people,
          label: 'Patients',
        ),
        AdaptiveDestination(
          icon: Icons.task_outlined,
          selectedIcon: Icons.task,
          label: 'Tasks',
          badge: 3,
        ),
        AdaptiveDestination(
          icon: Icons.chat_outlined,
          selectedIcon: Icons.chat,
          label: 'Chat',
          badge: 5,
        ),
        AdaptiveDestination(
          icon: Icons.monitor_heart_outlined,
          selectedIcon: Icons.monitor_heart,
          label: 'Vitals',
        ),
        AdaptiveDestination(
          icon: Icons.more_horiz,
          label: 'More',
        ),
      ],
      selectedIndex: _navIndex,
      onDestinationSelected: (i) => setState(() => _navIndex = i),
      breakpoints: AdaptiveBreakpoints.tabletFirst,
      child1: _PatientList(
        onTap: _handlePatientTap,
        selectedId: _selectedPatient?.id,
      ),
      child2: _selectedPatient != null
          ? _PatientDetail(patient: _selectedPatient!)
          : null,
      emptyDetailPlaceholder: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Select a patient to view details',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      ),
      railLeading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: FloatingActionButton.small(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

// ─── Patient list (child1) ───

class _PatientList extends StatelessWidget {
  const _PatientList({required this.onTap, this.selectedId});

  final ValueChanged<Patient> onTap;
  final int? selectedId;

  @override
  Widget build(BuildContext context) {
    final isTwoPane = AdaptiveShell.isTwoPane(context);

    return Column(
      children: [
        Padding(
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
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _patients.length,
            itemBuilder: (context, index) {
              final patient = _patients[index];
              final isSelected = selectedId == patient.id && isTwoPane;

              return Card(
                elevation: 0,
                color: isSelected
                    ? patient.color.withAlpha(20)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isSelected
                      ? BorderSide(color: patient.color.withAlpha(77))
                      : BorderSide.none,
                ),
                child: ListTile(
                  onTap: () => onTap(patient),
                  leading: CircleAvatar(
                    backgroundColor: patient.color.withAlpha(25),
                    foregroundColor: patient.color,
                    child: Text(
                      '${patient.priority}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    patient.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${patient.gender} | ${patient.age} | ${patient.bed}',
                  ),
                  trailing: isSelected
                      ? Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: patient.color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        )
                      : const Icon(Icons.chevron_right),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Patient detail (child2 on tablet, or pushed route on mobile) ───

class _PatientDetail extends StatelessWidget {
  const _PatientDetail({required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: patient.color.withAlpha(25),
                foregroundColor: patient.color,
                child: Text(
                  patient.name
                      .split(' ')
                      .map((w) => w[0])
                      .take(2)
                      .join(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${patient.gender} | ${patient.age} | ${patient.bed}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Vitals
          _section('Vitals', Icons.monitor_heart, patient.color, const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Vital(label: 'HR', value: '72', unit: 'bpm'),
              _Vital(label: 'BP', value: '120/80', unit: 'mmHg'),
              _Vital(label: 'Temp', value: '98.6', unit: 'F'),
              _Vital(label: 'SpO2', value: '98', unit: '%'),
            ],
          )),
          const SizedBox(height: 12),

          // Tasks
          _section('Pending Tasks', Icons.task, Colors.orange, const Column(
            children: [
              _Task(title: 'Collect CBC sample', due: '19 Aug 13:25', urgent: true),
              _Task(title: 'Change sheets', due: '09 Aug 18:45', urgent: false),
              _Task(title: 'Check references', due: '09 Sep 18:45', urgent: false),
            ],
          )),
          const SizedBox(height: 12),

          // Forms
          _section('Forms', Icons.description, Colors.green, const Column(
            children: [
              _Form(name: 'Skin Assessment', done: false, urgent: true),
              _Form(name: 'Pain Assessment', done: false, urgent: false),
              _Form(name: 'Glasgow Coma Scale', done: true, urgent: false),
            ],
          )),
        ],
      ),
    );
  }

  Widget _section(String title, IconData icon, Color color, Widget child) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _Vital extends StatelessWidget {
  const _Vital({required this.label, required this.value, required this.unit});
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        Text(unit, style: TextStyle(fontSize: 9, color: Colors.grey.shade400)),
      ],
    );
  }
}

class _Task extends StatelessWidget {
  const _Task({required this.title, required this.due, required this.urgent});
  final String title;
  final String due;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 4, height: 32,
            decoration: BoxDecoration(
              color: urgent ? Colors.orange : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                Text('Due: $due', style: TextStyle(fontSize: 10, color: Colors.red.shade400, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({required this.name, required this.done, required this.urgent});
  final String name;
  final bool done;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          if (done)
            const Icon(Icons.check_circle, size: 18, color: Colors.green)
          else
            Icon(
              urgent ? Icons.error_outline : Icons.radio_button_unchecked,
              size: 18,
              color: urgent ? Colors.red : Colors.grey.shade400,
            ),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              decoration: done ? TextDecoration.lineThrough : null,
              color: done ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }
}
