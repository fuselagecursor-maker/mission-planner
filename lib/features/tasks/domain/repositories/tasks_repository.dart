import '../models/agent.dart';
import '../models/mission_task.dart';

/// Contract for tasks + agents.
///
/// Future: replace with API-backed repository and add streams for real-time updates.
abstract class TasksRepository {
  Future<List<Agent>> listAgents();
  Future<List<MissionTask>> listTasks({String? missionId});
}

