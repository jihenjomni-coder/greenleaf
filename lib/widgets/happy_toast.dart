import 'package:material_ui/material_ui.dart';

import '../theme/greenleaf_theme.dart';

void showHappyWateredMessage(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      duration: const Duration(milliseconds: 2600),
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      backgroundColor: GreenleafColors.forestGreen,
      content: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: GreenleafColors.softYellow,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('💧', style: TextStyle(fontSize: 15)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: GreenleafColors.pureWhite,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
