import '../domain/models/mission.dart';
import '../domain/repositories/mission_repository.dart';

class DummyMissionRepository implements MissionRepository {
  DummyMissionRepository();

  static final _missions = <Mission>[
    Mission(
      id: 'm_001',
      name: 'Recon Alpha',
      description: 'Preliminary reconnaissance of sector A.',
      startDate: DateTime(2026, 4, 1),
      endDate: DateTime(2026, 4, 8),
      priority: MissionPriority.high,
      status: MissionStatus.active,
    ),
    Mission(
      id: 'm_002',
      name: 'Supply Drop',
      description: 'Deliver supplies to checkpoint B.',
      startDate: DateTime(2026, 3, 20),
      endDate: DateTime(2026, 3, 22),
      priority: MissionPriority.medium,
      status: MissionStatus.completed,
    ),
    Mission(
      id: 'm_003',
      name: 'Perimeter Patrol',
      description: 'Patrol perimeter and log anomalies.',
      startDate: DateTime(2026, 4, 6),
      endDate: DateTime(2026, 4, 9),
      priority: MissionPriority.low,
      status: MissionStatus.active,
    ),
    Mission(
      id: 'm_004',
      name: 'Grid survey (draft)',
      description: 'Photogrammetry grid — parameters not finalized.',
      startDate: DateTime(2026, 4, 10),
      endDate: DateTime(2026, 4, 12),
      priority: MissionPriority.medium,
      status: MissionStatus.draft,
    ),
  ];

  @override
  Future<List<Mission>> listMissions() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return List.unmodifiable(_missions);
  }

  @override
  Future<Mission?> getMissionById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _missions.where((m) => m.id == id).cast<Mission?>().firstOrNull;
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

