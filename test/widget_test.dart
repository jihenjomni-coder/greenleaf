import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:greenleaf/main.dart';
import 'package:greenleaf/models/plant.dart';
import 'package:greenleaf/services/supabase_plant_service.dart';
import 'package:greenleaf/state/plant_store.dart';

class _FakePlantRepository implements PlantRepository {
  _FakePlantRepository(this.plants);

  final List<Plant> plants;
  final List<String> wateredLogPlantIds = [];
  final List<String> createdPlantNames = [];

  @override
  Future<List<Plant>> fetchPlants() async => List<Plant>.from(plants);

  @override
  Future<Plant> createPlant(Plant plant) async {
    createdPlantNames.add(plant.name);
    final saved = plant.copyWith(id: 'db-${createdPlantNames.length}');
    plants.insert(0, saved);
    return saved;
  }

  @override
  Future<Plant> logWatering(Plant plant, {String? note}) async {
    wateredLogPlantIds.add(plant.id);
    final updated = plant.copyWith(lastWatered: DateTime.now());
    final idx = plants.indexWhere((p) => p.id == plant.id);
    if (idx != -1) {
      plants[idx] = updated;
    }
    return updated;
  }

  @override
  Future<void> deletePlant(String id) async {
    plants.removeWhere((p) => p.id == id);
  }
}

void main() {
  testWidgets(
      'greenleaf loads plants from repository, logs watering, and saves added plants',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 960);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeRepo = _FakePlantRepository(PlantStore.buildSamplePlants());

    await tester.pumpWidget(GreenleafApp(repository: fakeRepo));
    await tester.pumpAndSettle();

    // Home screen shows greenleaf header, synced label, and today's plants
    expect(find.text('greenleaf'), findsOneWidget);
    expect(find.text('Synced with Supabase'), findsOneWidget);
    expect(find.text('Money Plant'), findsOneWidget);

    // Tap Watered button on first due plant and verify watering_log was recorded
    await tester.tap(find.text('Watered').first);
    await tester.pumpAndSettle();
    expect(fakeRepo.wateredLogPlantIds, contains('money-plant'));

    // Navigate to My Plants and verify all 8 sample plants exist
    await tester.tap(find.text('My Plants'));
    await tester.pumpAndSettle();

    final expectedPlants = [
      'Money Plant',
      'Aloe Vera',
      'Snake Plant',
      'Tulsi',
      'Rose',
      'Mint',
      'Peace Lily',
      'Cactus',
    ];
    for (final name in expectedPlants) {
      await tester.scrollUntilVisible(
        find.text(name),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text(name), findsOneWidget);
    }

    // Open Plant Details for Cactus
    await tester.tap(find.text('Cactus'));
    await tester.pumpAndSettle();
    expect(find.text('Plant Details'), findsOneWidget);
    expect(find.text('Water every 14 days'), findsOneWidget);

    // Navigate back and save a new plant from Add Plant screen
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Plant'));
    await tester.pumpAndSettle();
    expect(find.text('Pick a Plant Emoji'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Lavender');
    final addButton = find.widgetWithText(ElevatedButton, 'Add Plant');
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(fakeRepo.createdPlantNames, contains('Lavender'));
    await tester.scrollUntilVisible(
      find.text('Lavender'),
      -250,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Lavender'), findsOneWidget);
  });
}
