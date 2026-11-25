class Plant {
  const Plant({
    required this.id,
    required this.name,
    required this.emoji,
    required this.room,
    required this.waterEveryDays,
    required this.lastWatered,
    this.sunlight = 'Bright indirect',
    this.careNote = 'Keep soil lightly moist and wipe leaves occasionally.',
  });

  final String id;
  final String name;
  final String emoji;
  final String room;
  final int waterEveryDays;
  final DateTime lastWatered;
  final String sunlight;
  final String careNote;

  factory Plant.fromMap(Map<String, dynamic> map) {
    final rawLastWatered = map['last_watered'];
    final DateTime parsedLastWatered = rawLastWatered is String
        ? DateTime.parse(rawLastWatered).toLocal()
        : DateTime.now();

    return Plant(
      id: map['id'].toString(),
      name: (map['name'] as String?)?.trim() ?? 'Plant',
      emoji: (map['emoji'] as String?)?.trim().isNotEmpty == true
          ? (map['emoji'] as String).trim()
          : '🌿',
      room: (map['room'] as String?)?.trim() ?? 'Living Room',
      waterEveryDays: (map['water_every_days'] as num?)?.toInt() ?? 3,
      lastWatered: parsedLastWatered,
      sunlight: (map['sunlight'] as String?)?.trim().isNotEmpty == true
          ? (map['sunlight'] as String).trim()
          : 'Bright indirect',
      careNote: (map['care_note'] as String?)?.trim().isNotEmpty == true
          ? (map['care_note'] as String).trim()
          : 'Keep soil lightly moist and enjoy watching your plant grow!',
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'name': name,
      'emoji': emoji,
      'room': room,
      'water_every_days': waterEveryDays,
      'last_watered': lastWatered.toUtc().toIso8601String(),
      'sunlight': sunlight,
      'care_note': careNote,
    };
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  int get daysSinceWatered {
    final today = _dateOnly(DateTime.now());
    final wateredDay = _dateOnly(lastWatered);
    return today.difference(wateredDay).inDays;
  }

  int get daysUntilNextWatering => waterEveryDays - daysSinceWatered;

  bool get isWateredToday => daysSinceWatered <= 0;

  bool get isDueToday => daysUntilNextWatering <= 0;

  String get scheduleLabel => waterEveryDays == 1
      ? 'Water every 1 day'
      : 'Water every $waterEveryDays days';

  String get lastWateredLabel {
    final days = daysSinceWatered;
    if (days <= 0) return 'Today';
    if (days == 1) return 'Yesterday';
    return '$days days ago';
  }

  String get statusLabel {
    if (isWateredToday) return 'Watered today';
    final until = daysUntilNextWatering;
    if (until <= 0) return 'Due today';
    if (until == 1) return 'Due tomorrow';
    return 'In $until days';
  }

  Plant copyWith({
    String? id,
    String? name,
    String? emoji,
    String? room,
    int? waterEveryDays,
    DateTime? lastWatered,
    String? sunlight,
    String? careNote,
  }) {
    return Plant(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      room: room ?? this.room,
      waterEveryDays: waterEveryDays ?? this.waterEveryDays,
      lastWatered: lastWatered ?? this.lastWatered,
      sunlight: sunlight ?? this.sunlight,
      careNote: careNote ?? this.careNote,
    );
  }
}
