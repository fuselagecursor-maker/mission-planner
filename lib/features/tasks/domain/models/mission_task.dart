enum TaskStatus { pending, active, completed }

class MissionTask {
  const MissionTask({
    required this.id,
    required this.missionId,
    required this.title,
    required this.assigneeId,
    required this.status,
  });

  final String id;
  final String missionId;
  final String title;
  final String assigneeId;
  final TaskStatus status;
}

