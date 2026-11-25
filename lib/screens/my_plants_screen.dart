import 'package:material_ui/material_ui.dart';

import '../models/plant.dart';
import '../state/plant_store.dart';
import '../theme/greenleaf_theme.dart';
import '../widgets/happy_toast.dart';
import '../widgets/plant_card.dart';
import 'plant_details_screen.dart';

class MyPlantsScreen extends StatefulWidget {
  const MyPlantsScreen({super.key});

  @override
  State<MyPlantsScreen> createState() => _MyPlantsScreenState();
}

class _MyPlantsScreenState extends State<MyPlantsScreen> {
  String _selectedRoom = 'All';

  void _openDetails(BuildContext context, Plant plant) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlantDetailsScreen(plantId: plant.id),
      ),
    );
  }

  Future<void> _waterPlant(BuildContext context, Plant plant) async {
    final store = PlantStoreScope.of(context);
    try {
      final message = await store.markWatered(plant.id);
      if (context.mounted) {
        showHappyWateredMessage(context, message);
      }
    } catch (error) {
      if (context.mounted) {
        showHappyWateredMessage(
          context,
          'Could not save watering to Supabase: $error',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = PlantStoreScope.of(context);
    final rooms = ['All', ...store.rooms];
    final activeRoom = rooms.contains(_selectedRoom) ? _selectedRoom : 'All';
    final plants = activeRoom == 'All'
        ? store.allPlants
        : store.allPlants.where((p) => p.room == activeRoom).toList();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Plants',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: GreenleafColors.forestGreen,
                          letterSpacing: -0.4,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tap any plant to view care details',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: GreenleafColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: GreenleafColors.mintTint,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '${store.allPlants.length} total',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: GreenleafColors.leafGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Room filter bar
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              scrollDirection: Axis.horizontal,
              itemCount: rooms.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final room = rooms[index];
                final isSelected = room == activeRoom;
                return ChoiceChip(
                  label: Text(room),
                  selected: isSelected,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _selectedRoom = room),
                  backgroundColor: GreenleafColors.pureWhite,
                  selectedColor: GreenleafColors.softYellow,
                  side: BorderSide(
                    color: isSelected
                        ? GreenleafColors.warmYellow
                        : GreenleafColors.borderGreen,
                  ),
                  labelStyle: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? GreenleafColors.deepHoney
                        : GreenleafColors.forestGreen,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: RefreshIndicator(
              color: GreenleafColors.leafGreen,
              onRefresh: store.loadPlants,
              child: plants.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'No plants in this room yet.',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: GreenleafColors.mutedText,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 2, 18, 24),
                      itemCount: plants.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final plant = plants[index];
                        return PlantCard(
                          plant: plant,
                          onTap: () => _openDetails(context, plant),
                          onWatered: () => _waterPlant(context, plant),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
