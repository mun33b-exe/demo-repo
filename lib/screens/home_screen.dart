import 'package:flutter/material.dart';
import 'package:demo_repo/widgets/weather_card.dart';
import 'package:demo_repo/screens/market_screen.dart';
import 'package:demo_repo/screens/community_screen.dart';
import 'package:demo_repo/screens/profile_screen.dart';
import 'package:demo_repo/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    const MarketScreen(),
    const CommunityScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: const Icon(Icons.storefront),
            label: l10n.market,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outlined),
            selectedIcon: const Icon(Icons.people),
            label: l10n.community,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  String _selectedCrop = 'Wheat';

  final Map<String, List<String>> _cropTips = {
    'Wheat': [
      'Sow wheat between Nov 1st and Nov 15th for best yield.',
      'Use 50kg seed per acre.',
      'Apply first irrigation 20-25 days after sowing.',
    ],
    'Rice': [
      'Maintain water level of 2-3 inches in the field.',
      'Apply Urea fertilizer in 2-3 splits.',
      'Monitor for stem borer attack.',
    ],
    'Cotton': [
      'Keep field free of weeds to avoid pests.',
      'Spray for whitefly if population exceeds ETL.',
      'Pick cotton when bolls are fully open.',
    ],
  };

  final List<Map<String, String>> _schemes = [
    {
      'title': 'Green Tractor Scheme',
      'description': 'Subsidy on tractors for small farmers.',
    },
    {
      'title': 'Kisan Card',
      'description': 'Direct cash subsidy for fertilizers and seeds.',
    },
    {
      'title': 'Solar Tube Well',
      'description': 'Interest-free loans for solar tube wells.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WeatherCard(),
            const SizedBox(height: 24),
            Text(
              l10n.welcomeMessage,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Crop Guidance Section
            Text(
              l10n.cropGuidance,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Center(
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'Wheat', label: Text(l10n.wheat)),
                  ButtonSegment(value: 'Rice', label: Text(l10n.rice)),
                  ButtonSegment(value: 'Cotton', label: Text(l10n.cotton)),
                ],
                selected: {_selectedCrop},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedCrop = newSelection.first;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _cropTips[_selectedCrop]!.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                    title: Text(_cropTips[_selectedCrop]![index]),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Government Schemes Section
            Text(
              l10n.governmentSchemes,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _schemes.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(
                      Icons.account_balance,
                      color: Colors.blue,
                    ),
                    title: Text(_schemes[index]['title']!),
                    subtitle: Text(_schemes[index]['description']!),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
