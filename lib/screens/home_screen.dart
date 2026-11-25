import 'package:material_ui/material_ui.dart';

import '../models/plant.dart';
import '../state/plant_store.dart';
import '../theme/greenleaf_theme.dart';
import '../widgets/happy_toast.dart';
import '../widgets/plant_card.dart';
import 'plant_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onGoToAddPlant});

  final VoidCallback onGoToAddPlant;

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
    final duePlants = store.dueTodayPlants;
    final wateredPlants = store.wateredTodayPlants;
    final totalToday = store.totalTodayTasks;
    final double progress =
        totalToday == 0 ? 1.0 : wateredPlants.length / totalToday;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: GreenleafColors.leafGreen,
        onRefresh: store.loadPlants,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Header
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: GreenleafColors.leafGreen,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text('🌿', style: TextStyle(fontSize: 20)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'greenleaf',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: GreenleafColors.forestGreen,
                                        letterSpacing: -0.5,
                                        height: 1.05,
                                      ),
                                    ),
                                    Text(
                                      store.isConnected
                                          ? 'Synced with Supabase'
                                          : 'Daily plant care',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: GreenleafColors.mutedText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: GreenleafColors.softYellow,
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                              color: GreenleafColors.warmYellow,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('☀️', style: TextStyle(fontSize: 13)),
                              const SizedBox(width: 4),
                              Text(
                                '${store.allPlants.length} plants',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: GreenleafColors.deepHoney,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (store.syncNotice != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: GreenleafColors.softYellow,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: GreenleafColors.warmYellow),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.cloud_outlined,
                              size: 18,
                              color: GreenleafColors.deepHoney,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                store.syncNotice!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: GreenleafColors.deepHoney,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: store.isLoading ? null : store.loadPlants,
                              style: TextButton.styleFrom(
                                foregroundColor: GreenleafColors.forestGreen,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Refresh',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (store.isLoading && store.allPlants.isEmpty) ...[
                      const SizedBox(height: 48),
                      const Center(
                        child: CircularProgressIndicator(
                          color: GreenleafColors.leafGreen,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  const SizedBox(height: 18),
                  // Today's Care Summary Card (soft yellow + green)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          GreenleafColors.softYellow,
                          Color(0xFFEAF7EC),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: GreenleafColors.warmYellow,
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    duePlants.isEmpty
                                        ? 'All caught up today!'
                                        : 'Today\'s Watering',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: GreenleafColors.forestGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    duePlants.isEmpty
                                        ? 'Every single leaf is happy and hydrated.'
                                        : '${duePlants.length} ${duePlants.length == 1 ? 'plant needs' : 'plants need'} a fresh drink today.',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: GreenleafColors.mutedText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 46,
                              height: 46,
                              decoration: const BoxDecoration(
                                color: GreenleafColors.pureWhite,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  duePlants.isEmpty ? '🌼' : '💧',
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor:
                                GreenleafColors.pureWhite.withValues(alpha: 0.8),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              GreenleafColors.leafGreen,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          totalToday == 0
                              ? 'Nothing due today'
                              : '${wateredPlants.length} of $totalToday watered today',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: GreenleafColors.forestGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Needs Water Today',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: GreenleafColors.forestGreen,
                          ),
                        ),
                      ),
                      if (duePlants.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: GreenleafColors.softYellow,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            '${duePlants.length} left',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: GreenleafColors.deepHoney,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          if (duePlants.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: GreenleafColors.pureWhite,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: GreenleafColors.borderGreen),
                  ),
                  child: Column(
                    children: [
                      const Text('🌻', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 10),
                      const Text(
                        'Your indoor garden is glowing!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: GreenleafColors.forestGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'All plants due today have been watered. Check back tomorrow or add a new green friend.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: GreenleafColors.mutedText,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: onGoToAddPlant,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add a Plant'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              sliver: SliverList.separated(
                itemCount: duePlants.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final plant = duePlants[index];
                  return PlantCard(
                    plant: plant,
                    showStatusBadge: false,
                    onTap: () => _openDetails(context, plant),
                    onWatered: () => _waterPlant(context, plant),
                  );
                },
              ),
            ),
          if (wateredPlants.isNotEmpty) ...[
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(18, 22, 18, 12),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Watered Today',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: GreenleafColors.forestGreen,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              sliver: SliverList.separated(
                itemCount: wateredPlants.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final plant = wateredPlants[index];
                  return PlantCard(
                    plant: plant,
                    onTap: () => _openDetails(context, plant),
                    onWatered: () => _waterPlant(context, plant),
                  );
                },
              ),
            ),
          ],
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
