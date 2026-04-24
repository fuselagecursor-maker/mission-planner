import '../models/mission.dart';

/// Contract for missions data.
///
/// Future: implement with REST/gRPC, local cache, offline sync, etc.
abstract class MissionRepository {
  Future<List<Mission>> listMissions();
  Future<Mission?> getMissionById(String id);
}

