import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/plant.dart';

abstract class PlantRepository {
  Future<List<Plant>> fetchPlants();
  Future<Plant> createPlant(Plant plant);
  Future<Plant> logWatering(Plant plant, {String? note});
  Future<void> deletePlant(String id);
}

class SupabasePlantRepository implements PlantRepository {
  SupabasePlantRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Plant>> fetchPlants() async {
    final response = await _client
        .from('plants')
        .select()
        .order('created_at', ascending: true);

    return (response as List<dynamic>)
        .map((row) => Plant.fromMap(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  @override
  Future<Plant> createPlant(Plant plant) async {
    final response = await _client
        .from('plants')
        .insert(plant.toInsertMap())
        .select()
        .single();

    return Plant.fromMap(Map<String, dynamic>.from(response));
  }

  @override
  Future<Plant> logWatering(Plant plant, {String? note}) async {
    final wateredAt = DateTime.now();
    final wateredAtIso = wateredAt.toUtc().toIso8601String();

    await _client.from('watering_log').insert({
      'plant_id': plant.id,
      'watered_at': wateredAtIso,
      'note': note ?? 'Watered ${plant.name}',
    });

    final updated = await _client
        .from('plants')
        .update({'last_watered': wateredAtIso})
        .eq('id', plant.id)
        .select()
        .single();

    return Plant.fromMap(Map<String, dynamic>.from(updated));
  }

  @override
  Future<void> deletePlant(String id) async {
    await _client.from('plants').delete().eq('id', id);
  }
}
