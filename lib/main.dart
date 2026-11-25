import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/main_shell.dart';
import 'services/supabase_plant_service.dart';
import 'state/plant_store.dart';
import 'theme/greenleaf_theme.dart';
import 'widgets/responsive_phone_frame.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PlantRepository? repository;
  try {
    await dotenv.load(fileName: '.env');
    final supabaseUrl = (dotenv.env['SUPSBASE_PROJECT_URL'] ??
            dotenv.env['SUPABASE_URL'] ??
            '')
        .trim();
    final supabaseKey = (dotenv.env['SUPABASE_PUBLIC_KEY'] ??
            dotenv.env['SUPABASE_ANON_KEY'] ??
            '')
        .trim();

    if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseKey,
      );
      repository = SupabasePlantRepository(Supabase.instance.client);
    }
  } catch (error) {
    debugPrint('Supabase initialization error: $error');
  }

  runApp(GreenleafApp(repository: repository));
}

class GreenleafApp extends StatefulWidget {
  const GreenleafApp({super.key, this.repository});

  final PlantRepository? repository;

  @override
  State<GreenleafApp> createState() => _GreenleafAppState();
}

class _GreenleafAppState extends State<GreenleafApp> {
  late final PlantStore _store;

  @override
  void initState() {
    super.initState();
    _store = PlantStore(repository: widget.repository);
    if (widget.repository != null) {
      _store.loadPlants();
    }
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlantStoreScope(
      store: _store,
      child: MaterialApp(
        title: 'greenleaf',
        debugShowCheckedModeBanner: false,
        theme: GreenleafTheme.lightTheme,
        builder: (context, child) {
          return ResponsivePhoneFrame(
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const MainShell(),
      ),
    );
  }
}
