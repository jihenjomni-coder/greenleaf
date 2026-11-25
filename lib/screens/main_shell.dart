import 'package:material_ui/material_ui.dart';

import '../theme/greenleaf_theme.dart';
import 'add_plant_screen.dart';
import 'home_screen.dart';
import 'my_plants_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(onGoToAddPlant: () => _selectTab(2)),
          const MyPlantsScreen(),
          AddPlantScreen(onPlantAdded: () => _selectTab(1)),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: GreenleafColors.pureWhite,
          border: Border(
            top: BorderSide(color: GreenleafColors.borderGreen, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _selectTab,
          backgroundColor: GreenleafColors.pureWhite,
          indicatorColor: GreenleafColors.softYellow,
          surfaceTintColor: Colors.transparent,
          height: 68,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(
                Icons.home_outlined,
                color: GreenleafColors.mutedText,
              ),
              selectedIcon: Icon(
                Icons.home_rounded,
                color: GreenleafColors.forestGreen,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.eco_outlined,
                color: GreenleafColors.mutedText,
              ),
              selectedIcon: Icon(
                Icons.eco_rounded,
                color: GreenleafColors.forestGreen,
              ),
              label: 'My Plants',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.add_circle_outline_rounded,
                color: GreenleafColors.mutedText,
              ),
              selectedIcon: Icon(
                Icons.add_circle_rounded,
                color: GreenleafColors.forestGreen,
              ),
              label: 'Add Plant',
            ),
          ],
        ),
      ),
    );
  }
}
