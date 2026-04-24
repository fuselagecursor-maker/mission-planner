enum AgentStatus { available, busy, offline }

class Agent {
  const Agent({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
  });

  final String id;
  final String name;
  final String role;
  final AgentStatus status;
}

