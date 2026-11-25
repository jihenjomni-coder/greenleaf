import 'package:material_ui/material_ui.dart';

import '../models/plant.dart';
import '../theme/greenleaf_theme.dart';

class PlantCard extends StatelessWidget {
  const PlantCard({
    super.key,
    required this.plant,
    required this.onTap,
    required this.onWatered,
    this.showStatusBadge = true,
  });

  final Plant plant;
  final VoidCallback onTap;
  final VoidCallback onWatered;
  final bool showStatusBadge;

  @override
  Widget build(BuildContext context) {
    final bool isDue = plant.isDueToday;
    final bool isDone = plant.isWateredToday;

    return Material(
      color: GreenleafColors.pureWhite,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDue
                  ? GreenleafColors.warmYellow
                  : GreenleafColors.borderGreen,
              width: isDue ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: GreenleafColors.forestGreen.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Plant emoji badge
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isDue
                      ? GreenleafColors.softYellow
                      : GreenleafColors.mintTint,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    plant.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 11),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Text(
                          plant.name,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: GreenleafColors.forestGreen,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (showStatusBadge) _StatusChip(plant: plant),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.room_outlined,
                          size: 14,
                          color: GreenleafColors.mutedText,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            plant.room,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: GreenleafColors.mutedText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.water_drop_outlined,
                          size: 14,
                          color: GreenleafColors.leafGreen,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            plant.scheduleLabel,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: GreenleafColors.leafGreen,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Watered action button
              _WateredButton(
                isDone: isDone,
                onPressed: onWatered,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context) {
    final bool isDue = plant.isDueToday;
    final bool isDone = plant.isWateredToday;

    final Color bgColor;
    final Color fgColor;

    if (isDone) {
      bgColor = GreenleafColors.mintTint;
      fgColor = GreenleafColors.leafGreen;
    } else if (isDue) {
      bgColor = GreenleafColors.softYellow;
      fgColor = GreenleafColors.deepHoney;
    } else {
      bgColor = const Color(0xFFF1F5F2);
      fgColor = GreenleafColors.mutedText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        plant.statusLabel,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: fgColor,
        ),
      ),
    );
  }
}

class _WateredButton extends StatelessWidget {
  const _WateredButton({
    required this.isDone,
    required this.onPressed,
  });

  final bool isDone;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDone ? GreenleafColors.mintTint : GreenleafColors.leafGreen,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDone ? Icons.check_circle_rounded : Icons.water_drop_rounded,
                size: 15,
                color: isDone
                    ? GreenleafColors.leafGreen
                    : GreenleafColors.pureWhite,
              ),
              const SizedBox(width: 4),
              Text(
                'Watered',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDone
                      ? GreenleafColors.leafGreen
                      : GreenleafColors.pureWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
