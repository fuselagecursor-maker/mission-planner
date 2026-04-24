import '../domain/models/agent.dart';
import '../domain/models/mission_task.dart';
import '../domain/repositories/tasks_repository.dart';

class DummyTasksRepository implements TasksRepository {
  DummyTasksRepository();

  static final _agents = <Agent>[
    Agent(id: 'a_001', name: 'A. Patel', role: 'Operator', status: AgentStatus.available),
    Agent(id: 'a_002', name: 'S. Kim', role: 'Navigator', status: AgentStatus.busy),
    Agent(id: 'a_003', name: 'J. Rivera', role: 'Analyst', status: AgentStatus.available),
    Agent(id: 'a_004', name: 'M. Chen', role: 'Supervisor', status: AgentStatus.offline),
  ];

  static final _tasks = <MissionTask>[
    MissionTask(
      id: 't_001',
      missionId: 'm_001',
      title: 'Confirm ingress route',
      assigneeId: 'a_002',
      status: TaskStatus.active,
    ),
    MissionTask(
      id: 't_002',
      missionId: 'm_001',
      title: 'Capture imagery at waypoint 3',
      assigneeId: 'a_001',
      status: TaskStatus.pending,
    ),
    MissionTask(
      id: 't_003',
      missionId: 'm_003',
      title: 'Review anomaly logs',
      assigneeId: 'a_003',
      status: TaskStatus.completed,
    ),
  ];

  @override
  Future<List<Agent>> listAgents() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return List.unmodifiable(_agents);
  }

  @override
  Future<List<MissionTask>> listTasks({String? missionId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final filtered = missionId == null
        ? _tasks
        : _tasks.where((t) => t.missionId == missionId).toList();
    return List.unmodifiable(filtered);
  }
}

