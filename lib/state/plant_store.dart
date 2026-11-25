import 'package:flutter/widgets.dart';

import '../models/plant.dart';
import '../services/supabase_plant_service.dart';

class PlantStore extends ChangeNotifier {
  PlantStore({PlantRepository? repository})
      : _repository = repository,
        _plants = repository == null ? buildSamplePlants() : <Plant>[];

  final PlantRepository? _repository;
  List<Plant> _plants;
  final Set<String> _wateredTodayIds = <String>{};
  int _messageIndex = 0;

  bool _isLoading = false;
  bool _isConnected = false;
  String? _syncNotice;

  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  String? get syncNotice => _syncNotice;
  bool get hasRepository => _repository != null;

  static List<Plant> buildSamplePlants() {
    final now = DateTime.now();
    DateTime daysAgo(int d) => now.subtract(Duration(days: d));

    return [
      Plant(
        id: 'money-plant',
        name: 'Money Plant',
        emoji: '🍀',
        room: 'Living Room',
        waterEveryDays: 3,
        lastWatered: daysAgo(3),
        sunlight: 'Bright indirect',
        careNote:
            'Loves gentle morning light and trailing from a bright shelf. Let the top inch of soil dry slightly between waterings.',
      ),
      Plant(
        id: 'aloe-vera',
        name: 'Aloe Vera',
        emoji: '🌿',
        room: 'Sunny Window',
        waterEveryDays: 10,
        lastWatered: daysAgo(6),
        sunlight: 'Full sun',
        careNote:
            'Soak deeply and let the soil dry out completely before watering again. Great on a warm windowsill.',
      ),
      Plant(
        id: 'snake-plant',
        name: 'Snake Plant',
        emoji: '🎍',
        room: 'Bedroom',
        waterEveryDays: 14,
        lastWatered: daysAgo(7),
        sunlight: 'Low to bright',
        careNote:
            'Thrives on gentle neglect and purifies bedroom air. Avoid soggy roots by watering sparingly.',
      ),
      Plant(
        id: 'tulsi',
        name: 'Tulsi',
        emoji: '🌱',
        room: 'Balcony',
        waterEveryDays: 2,
        lastWatered: daysAgo(2),
        sunlight: 'Full sun',
        careNote:
            'Enjoys warm sunshine and steady moisture. Pinch off flower spikes occasionally to encourage lush, fragrant leaves.',
      ),
      Plant(
        id: 'rose',
        name: 'Rose',
        emoji: '🌹',
        room: 'Balcony',
        waterEveryDays: 2,
        lastWatered: daysAgo(2),
        sunlight: 'Full sun',
        careNote:
            'Water right at the base in the morning to keep foliage fresh and encourage vibrant blooms.',
      ),
      Plant(
        id: 'mint',
        name: 'Mint',
        emoji: '🍃',
        room: 'Kitchen',
        waterEveryDays: 1,
        lastWatered: daysAgo(1),
        sunlight: 'Bright indirect',
        careNote:
            'Loves consistently damp soil and regular harvesting. Snip the top stems to keep it bushy and aromatic.',
      ),
      Plant(
        id: 'peace-lily',
        name: 'Peace Lily',
        emoji: '🌼',
        room: 'Living Room',
        waterEveryDays: 4,
        lastWatered: daysAgo(4),
        sunlight: 'Low to bright',
        careNote:
            'Droops slightly when thirsty and perks right back up after a drink. Mist leaves for a happy tropical glow.',
      ),
      Plant(
        id: 'cactus',
        name: 'Cactus',
        emoji: '🌵',
        room: 'Study Desk',
        waterEveryDays: 14,
        lastWatered: daysAgo(5),
        sunlight: 'Full sun',
        careNote:
            'Needs plenty of light and very little water. Use a pot with a drainage hole so roots stay dry and strong.',
      ),
    ];
  }

  List<Plant> get allPlants => List.unmodifiable(_plants);

  List<Plant> get dueTodayPlants =>
      _plants.where((plant) => plant.isDueToday).toList(growable: false);

  List<Plant> get wateredTodayPlants => _plants
      .where(
        (plant) => plant.isWateredToday || _wateredTodayIds.contains(plant.id),
      )
      .toList(growable: false);

  int get totalTodayTasks => dueTodayPlants.length + wateredTodayPlants.length;

  List<String> get rooms {
    final uniqueRooms = <String>[];
    for (final plant in _plants) {
      if (!uniqueRooms.contains(plant.room)) {
        uniqueRooms.add(plant.room);
      }
    }
    return uniqueRooms;
  }

  Plant? findById(String id) {
    for (final plant in _plants) {
      if (plant.id == id) return plant;
    }
    return null;
  }

  Future<void> loadPlants() async {
    final repo = _repository;
    if (repo == null) return;

    _isLoading = true;
    _syncNotice = null;
    notifyListeners();

    try {
      final fetched = await repo.fetchPlants();
      _plants = fetched;
      _wateredTodayIds
        ..clear()
        ..addAll(fetched.where((p) => p.isWateredToday).map((p) => p.id));
      _isConnected = true;
      _syncNotice = null;
    } catch (error) {
      _isConnected = false;
      if (_plants.isEmpty) {
        _plants = buildSamplePlants();
      }
      final msg = error.toString();
      if (msg.contains('PGRST205') || msg.contains('public.plants')) {
        _syncNotice =
            'Supabase connected! Run the SQL script to create the plants and watering_log tables, then tap Refresh.';
      } else {
        _syncNotice = 'Showing sample plants (Supabase sync error: $msg)';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _nextHappyMessage(Plant plant) {
    final messages = [
      'Yay! ${plant.emoji} ${plant.name} is hydrated and happy!',
      'Refreshing! ${plant.emoji} ${plant.name} says thank you!',
      'Splish splash! ${plant.emoji} ${plant.name} is thriving today!',
      'Lovely care! ${plant.emoji} ${plant.name} feels super fresh!',
      'Happy leaves! ${plant.emoji} ${plant.name} is glowing!',
    ];
    final message = messages[_messageIndex % messages.length];
    _messageIndex++;
    return message;
  }

  Future<String> markWatered(String id) async {
    final index = _plants.indexWhere((plant) => plant.id == id);
    if (index == -1) return 'Plant watered!';

    final plant = _plants[index];
    final previous = plant;
    _plants[index] = plant.copyWith(lastWatered: DateTime.now());
    _wateredTodayIds.add(id);
    notifyListeners();

    final repo = _repository;
    if (repo != null && _isConnected) {
      try {
        final updated = await repo.logWatering(plant);
        final currentIndex = _plants.indexWhere((p) => p.id == id);
        if (currentIndex != -1) {
          _plants[currentIndex] = updated;
          notifyListeners();
        }
      } catch (error) {
        final currentIndex = _plants.indexWhere((p) => p.id == id);
        if (currentIndex != -1) {
          _plants[currentIndex] = previous;
          if (!previous.isWateredToday) {
            _wateredTodayIds.remove(id);
          }
          notifyListeners();
        }
        rethrow;
      }
    }

    return _nextHappyMessage(plant);
  }

  Future<Plant> addPlant({
    required String name,
    required String emoji,
    required String room,
    required int waterEveryDays,
    required bool dueToday,
    required String sunlight,
    required String careNote,
  }) async {
    final now = DateTime.now();
    final draft = Plant(
      id: 'plant-${now.microsecondsSinceEpoch}',
      name: name.trim(),
      emoji: emoji,
      room: room.trim(),
      waterEveryDays: waterEveryDays,
      lastWatered: dueToday ? now.subtract(Duration(days: waterEveryDays)) : now,
      sunlight: sunlight,
      careNote: careNote.trim().isEmpty
          ? 'Check the soil gently and enjoy watching your ${name.trim()} grow!'
          : careNote.trim(),
    );

    final repo = _repository;
    final Plant saved;
    if (repo != null && _isConnected) {
      saved = await repo.createPlant(draft);
    } else {
      saved = draft;
    }

    _plants.insert(0, saved);
    if (!dueToday) {
      _wateredTodayIds.add(saved.id);
    }
    notifyListeners();
    return saved;
  }

  Future<void> deletePlant(String id) async {
    final repo = _repository;
    if (repo != null && _isConnected) {
      await repo.deletePlant(id);
    }
    _plants.removeWhere((plant) => plant.id == id);
    _wateredTodayIds.remove(id);
    notifyListeners();
  }
}

class PlantStoreScope extends InheritedNotifier<PlantStore> {
  const PlantStoreScope({
    super.key,
    required PlantStore store,
    required super.child,
  }) : super(notifier: store);

  static PlantStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PlantStoreScope>();
    assert(scope != null, 'PlantStoreScope not found in widget tree');
    return scope!.notifier!;
  }
}
