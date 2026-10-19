import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'screens/event_list_screen.dart';
import 'screens/competition_list_screen.dart';
import 'screens/my_registrations_screen.dart';
import 'widgets/event_theme.dart';

/// Point d'entrée du module Événements et Compétitions.
/// Intégré à l'index 3 de l'IndexedStack de HomeScreen.
///
/// Affiche 3 sous-onglets internes :
///   0 — Événements
///   1 — Compétitions
///   2 — Mes inscriptions (utilisateur connecté uniquement)
class EventModule extends StatefulWidget {
  const EventModule({super.key});

  @override
  State<EventModule> createState() => _EventModuleState();
}

class _EventModuleState extends State<EventModule>
    with SingleTickerProviderStateMixin {
  int?  _userId;
  bool  _ready = false;
  late  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSession();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSession() async {
    final id = await AuthService().getCurrentUserId();
    if (mounted) setState(() { _userId = id; _ready = true; });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        backgroundColor: EventTheme.bg,
        body: Center(child: CircularProgressIndicator(color: EventTheme.mint)),
      );
    }

    return Scaffold(
      backgroundColor: EventTheme.bg,
      // Barre d'onglets interne (dans le body, pas dans l'AppBar globale)
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          // En-tête
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: EventTheme.screenPadding, vertical: 10),
            child: Row(children: [
              Builder(builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: EventTheme.text),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              )),
              const SizedBox(width: 6),
              const Text('Événements', style: EventTheme.titleStyle),
            ]),
          ),

          // Barre d'onglets interne
          Container(
            margin: const EdgeInsets.symmetric(horizontal: EventTheme.screenPadding),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: EventTheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: EventTheme.mint.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: EventTheme.mint.withValues(alpha: 0.45)),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: EventTheme.mint,
              unselectedLabelColor: EventTheme.textSoft,
              labelStyle: const TextStyle(
                  fontFamily: EventTheme.fontFamily,
                  fontWeight: FontWeight.bold, fontSize: 12),
              unselectedLabelStyle: const TextStyle(
                  fontFamily: EventTheme.fontFamily, fontSize: 12),
              tabs: const [
                Tab(text: 'Événements'),
                Tab(text: 'Compétitions'),
                Tab(text: 'Mes inscrip.'),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Contenu des onglets
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Onglet 0 — Événements
                EventListScreen(currentUserId: _userId),

                // Onglet 1 — Compétitions
                CompetitionListScreen(currentUserId: _userId),

                // Onglet 2 — Mes inscriptions
                _userId != null
                    ? MyRegistrationsScreen(currentUserId: _userId!)
                    : _buildLoginPrompt(),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.lock_outline,
              size: 64, color: EventTheme.textSoft.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text('Connectez-vous pour accéder à vos inscriptions.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: EventTheme.fontFamily,
                  fontSize: 15,
                  color: EventTheme.textSoft)),
        ]),
      ),
    );
  }
}
