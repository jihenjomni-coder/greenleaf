import 'package:material_ui/material_ui.dart';

import '../state/plant_store.dart';
import '../theme/greenleaf_theme.dart';
import '../widgets/happy_toast.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key, required this.onPlantAdded});

  final VoidCallback onPlantAdded;

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roomController = TextEditingController(text: 'Living Room');
  final _noteController = TextEditingController();

  static const List<String> _emojiOptions = [
    '🌿',
    '🍀',
    '🌱',
    '🌹',
    '🍃',
    '🌼',
    '🌵',
    '🎍',
    '🌷',
    '🌻',
    '🌺',
    '🌸',
  ];

  static const List<String> _roomPresets = [
    'Living Room',
    'Balcony',
    'Bedroom',
    'Kitchen',
    'Sunny Window',
    'Study Desk',
  ];

  static const List<String> _sunlightOptions = [
    'Bright indirect',
    'Full sun',
    'Low to bright',
  ];

  String _selectedEmoji = '🌿';
  int _waterEveryDays = 3;
  bool _dueToday = true;
  String _sunlight = 'Bright indirect';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _roomController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _savePlant() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final store = PlantStoreScope.of(context);
      final plant = await store.addPlant(
        name: _nameController.text,
        emoji: _selectedEmoji,
        room: _roomController.text,
        waterEveryDays: _waterEveryDays,
        dueToday: _dueToday,
        sunlight: _sunlight,
        careNote: _noteController.text,
      );

      if (!mounted) return;
      showHappyWateredMessage(
        context,
        'Welcome ${plant.emoji} ${plant.name} to greenleaf!',
      );

      _nameController.clear();
      _noteController.clear();
      setState(() {
        _selectedEmoji = '🌿';
        _waterEveryDays = 3;
        _dueToday = true;
        _sunlight = 'Bright indirect';
        _roomController.text = 'Living Room';
      });

      widget.onPlantAdded();
    } catch (error) {
      if (mounted) {
        showHappyWateredMessage(
          context,
          'Could not save plant to Supabase: $error',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add Plant',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: GreenleafColors.forestGreen,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Add a new leafy friend to your watering schedule',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: GreenleafColors.mutedText,
                ),
              ),
              const SizedBox(height: 18),
              // Emoji picker
              const _FieldLabel('Pick a Plant Emoji'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _emojiOptions.map((emoji) {
                  final isSelected = emoji == _selectedEmoji;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = emoji),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? GreenleafColors.softYellow
                            : GreenleafColors.pureWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? GreenleafColors.leafGreen
                              : GreenleafColors.borderGreen,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(emoji, style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              // Plant name
              const _FieldLabel('Plant Name'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g. Monstera, Lavender, Basil',
                  prefixIcon: Icon(
                    Icons.eco_outlined,
                    color: GreenleafColors.leafGreen,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a plant name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              // Room
              const _FieldLabel('Room'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _roomController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Where does this plant live?',
                  prefixIcon: Icon(
                    Icons.room_outlined,
                    color: GreenleafColors.leafGreen,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a room';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _roomPresets.map((room) {
                  final isSelected = _roomController.text == room;
                  return ActionChip(
                    label: Text(room),
                    backgroundColor: isSelected
                        ? GreenleafColors.mintTint
                        : GreenleafColors.pureWhite,
                    side: const BorderSide(color: GreenleafColors.borderGreen),
                    labelStyle: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: GreenleafColors.forestGreen,
                    ),
                    onPressed: () {
                      setState(() => _roomController.text = room);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              // Watering frequency card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: GreenleafColors.pureWhite,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: GreenleafColors.borderGreen),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        const _FieldLabel('Watering Schedule'),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: GreenleafColors.softYellow,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            _waterEveryDays == 1
                                ? 'Water every 1 day'
                                : 'Water every $_waterEveryDays days',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: GreenleafColors.deepHoney,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _waterEveryDays.toDouble(),
                      min: 1,
                      max: 21,
                      divisions: 20,
                      activeColor: GreenleafColors.leafGreen,
                      inactiveColor: GreenleafColors.mintTint,
                      onChanged: (value) {
                        setState(() => _waterEveryDays = value.round());
                      },
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Needs water today',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: GreenleafColors.forestGreen,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Show on Home screen right away',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: GreenleafColors.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch.adaptive(
                          activeTrackColor: GreenleafColors.leafGreen,
                          value: _dueToday,
                          onChanged: (value) =>
                              setState(() => _dueToday = value),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Sunlight
              const _FieldLabel('Sunlight'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _sunlightOptions.map((option) {
                  final selected = option == _sunlight;
                  return ChoiceChip(
                    label: Text(option),
                    selected: selected,
                    showCheckmark: false,
                    backgroundColor: GreenleafColors.pureWhite,
                    selectedColor: GreenleafColors.softYellow,
                    side: BorderSide(
                      color: selected
                          ? GreenleafColors.warmYellow
                          : GreenleafColors.borderGreen,
                    ),
                    labelStyle: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? GreenleafColors.deepHoney
                          : GreenleafColors.forestGreen,
                    ),
                    onSelected: (_) => setState(() => _sunlight = option),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Optional note
              const _FieldLabel('Care Note (optional)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Mist leaves weekly, keep near east window...',
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _savePlant,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: GreenleafColors.pureWhite,
                          ),
                        )
                      : const Icon(Icons.add_circle_outline_rounded),
                  label: Text(
                    _isSaving ? 'Saving...' : 'Add Plant',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w800,
        color: GreenleafColors.forestGreen,
      ),
    );
  }
}
