/// An adaptive master-detail layout wrapper for Flutter.
///
/// Automatically switches between [NavigationBar] (mobile) and
/// [NavigationRail] (tablet/web/desktop), showing `child1` always and
/// `child2` beside it on larger screens.
///
/// ```dart
/// AdaptiveShell(
///   destinations: [
///     AdaptiveDestination(icon: Icons.people, label: 'Patients'),
///     AdaptiveDestination(icon: Icons.task, label: 'Tasks'),
///   ],
///   selectedIndex: _index,
///   onDestinationSelected: (i) => setState(() => _index = i),
///   child1: PatientListScreen(),
///   child2: PatientDetailScreen(),
/// )
/// ```
///
/// Use [AdaptiveShell.of] to read the current [LayoutMode] in descendants
/// and decide whether to push a route (compact) or update state
/// (medium/expanded).
library;

export 'src/adaptive_shell.dart';
export 'src/adaptive_master_detail.dart';
export 'src/adaptive_destination.dart';
export 'src/breakpoints.dart';
export 'src/layout_mode.dart';
export 'src/adaptive_extensions.dart';
export 'src/adaptive_builder.dart';
