import 'package:material_ui/material_ui.dart';

import '../state/plant_store.dart';
import '../theme/greenleaf_theme.dart';
import '../widgets/happy_toast.dart';

class PlantDetailsScreen extends StatelessWidget {
  const PlantDetailsScreen({super.key, required this.plantId});

  final String plantId;

  Future<void> _confirmDelete(BuildContext context, String plantName) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: GreenleafColors.pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Remove plant?',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: GreenleafColors.forestGreen,
          ),
        ),
        content: Text(
          'Remove $plantName from your greenleaf collection?',
          style: const TextStyle(color: GreenleafColors.mutedText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD64545),
              foregroundColor: GreenleafColors.pureWhite,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      try {
        await PlantStoreScope.of(context).deletePlant(plantId);
        if (context.mounted) {
          Navigator.of(context).pop();
          showHappyWateredMessage(context, '$plantName removed from My Plants.');
        }
      } catch (error) {
        if (context.mounted) {
          showHappyWateredMessage(
            context,
            'Could not remove plant from Supabase: $error',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = PlantStoreScope.of(context);
    final plant = store.findById(plantId);

    if (plant == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Plant Details')),
        body: const Center(child: Text('Plant not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Details'),
        actions: [
          IconButton(
            tooltip: 'Remove plant',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _confirmDelete(context, plant.name),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero botanical card
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 26,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            GreenleafColors.softYellow,
                            GreenleafColors.pureWhite,
                            GreenleafColors.mintTint,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: GreenleafColors.borderGreen,
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 104,
                            height: 104,
                            decoration: BoxDecoration(
                              color: GreenleafColors.pureWhite,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: GreenleafColors.warmYellow,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: GreenleafColors.forestGreen
                                      .withValues(alpha: 0.08),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                plant.emoji,
                                style: const TextStyle(fontSize: 54),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            plant.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: GreenleafColors.forestGreen,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _DetailPill(
                                icon: Icons.room_outlined,
                                text: plant.room,
                                bgColor: GreenleafColors.pureWhite,
                                fgColor: GreenleafColors.forestGreen,
                              ),
                              _DetailPill(
                                icon: plant.isWateredToday
                                    ? Icons.check_circle_rounded
                                    : Icons.water_drop_rounded,
                                text: plant.statusLabel,
                                bgColor: plant.isWateredToday
                                    ? GreenleafColors.mintTint
                                    : GreenleafColors.softYellow,
                                fgColor: plant.isWateredToday
                                    ? GreenleafColors.leafGreen
                                    : GreenleafColors.deepHoney,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Care stats grid
                    Row(
                      children: [
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.water_drop_rounded,
                            label: 'Schedule',
                            value: plant.scheduleLabel,
                            tint: GreenleafColors.mintTint,
                            iconColor: GreenleafColors.leafGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.calendar_today_rounded,
                            label: 'Last Watered',
                            value: plant.lastWateredLabel,
                            tint: GreenleafColors.softYellow,
                            iconColor: GreenleafColors.deepHoney,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.wb_sunny_rounded,
                            label: 'Sunlight',
                            value: plant.sunlight,
                            tint: GreenleafColors.softYellow,
                            iconColor: GreenleafColors.deepHoney,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.home_outlined,
                            label: 'Room',
                            value: plant.room,
                            tint: GreenleafColors.mintTint,
                            iconColor: GreenleafColors.leafGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Care Tip Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: GreenleafColors.softYellow,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: GreenleafColors.warmYellow),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text('✨', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 6),
                              Text(
                                'Care Tip',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: GreenleafColors.deepHoney,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            plant.careNote,
                            style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                              color: GreenleafColors.forestGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Sticky Watered CTA
            Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
              decoration: const BoxDecoration(
                color: GreenleafColors.pureWhite,
                border: Border(
                  top: BorderSide(color: GreenleafColors.borderGreen),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
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
                  },
                  icon: Icon(
                    plant.isWateredToday
                        ? Icons.check_circle_rounded
                        : Icons.water_drop_rounded,
                  ),
                  label: Text(
                    plant.isWateredToday ? 'Watered Again' : 'Watered',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  const _DetailPill({
    required this.icon,
    required this.text,
    required this.bgColor,
    required this.fgColor,
  });

  final IconData icon;
  final String text;
  final Color bgColor;
  final Color fgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: GreenleafColors.borderGreen),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: fgColor),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tint;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GreenleafColors.pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GreenleafColors.borderGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: GreenleafColors.mutedText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: GreenleafColors.forestGreen,
            ),
          ),
        ],
      ),
    );
  }
}
