enum MissionPriority { low, medium, high, critical }

enum MissionStatus { draft, active, completed }

class Mission {
  const Mission({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.priority,
    required this.status,
  });

  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final MissionPriority priority;
  final MissionStatus status;
}

