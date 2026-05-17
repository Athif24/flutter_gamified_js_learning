class EventModel {
  final String id;
  final String name;
  final String? description;
  final String eventType;
  final int xpReward;
  final int jewelReward;
  final String? startDate;
  final String? endDate;

  const EventModel({
    required this.id,
    required this.name,
    this.description,
    required this.eventType,
    this.xpReward = 0,
    this.jewelReward = 0,
    this.startDate,
    this.endDate,
  });

  bool get isActive {
    if (endDate == null) return true;
    final end = DateTime.tryParse(endDate!);
    if (end == null) return true;
    return DateTime.now().isBefore(end);
  }

  factory EventModel.fromJson(Map<String, dynamic> j) {
    final d = j['data'] ?? j;
    return EventModel(
      id         : d['id']?.toString() ?? '',
      name       : d['name'] ?? '',
      description: d['description'] as String?,
      eventType  : d['event_type'] ?? d['eventType'] ?? 'daily_mission',
      xpReward   : (d['xp_reward'] ?? d['xpReward'] ?? 0) as int,
      jewelReward: (d['jewel_reward'] ?? d['jewelReward'] ?? 0) as int,
      startDate  : d['start_date']?.toString() ?? d['startDate']?.toString(),
      endDate    : d['end_date']?.toString() ?? d['endDate']?.toString(),
    );
  }
}
