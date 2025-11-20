import 'package:flutter/material.dart';
import 'package:demo_repo/services/weather_service.dart';
import 'package:demo_repo/screens/market_screen.dart';
import 'package:demo_repo/screens/community_screen.dart';
import 'package:demo_repo/screens/profile_screen.dart';
import 'package:intl/intl.dart';
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
  final WeatherService _weatherService = WeatherService();
  late Future<Map<String, dynamic>> _weatherFuture;
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
  void initState() {
    super.initState();
    _weatherFuture = _weatherService.fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weather Section
            Text('${l10n.weather} (Islamabad)',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            FutureBuilder<Map<String, dynamic>>(
              future: _weatherFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Card(
                      child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Failed to load weather'),
                  ));
                } else if (snapshot.hasData) {
                  final current = snapshot.data!['current'];
                  final daily = snapshot.data!['daily'];
                  final temp = current['temperature_2m'];
                  
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.currentTemperature,
                                      style: Theme.of(context).textTheme.bodyMedium),
                                  Text('$temp°C',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium
                                          ?.copyWith(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const Icon(Icons.wb_sunny,
                                  size: 48, color: Colors.orange),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 80,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 5,
                              itemBuilder: (context, index) {
                                final maxTemp = daily['temperature_2m_max'][index];
                                final minTemp = daily['temperature_2m_min'][index];
                                final date = DateTime.now().add(Duration(days: index));
                                return Container(
                                  width: 70,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(DateFormat('E').format(date)),
                                      const SizedBox(height: 4),
                                      Text('$maxTemp°/$minTemp°', style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
            const SizedBox(height: 24),

            // Crop Guidance Section
            Text(l10n.cropGuidance, style: Theme.of(context).textTheme.titleLarge),
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
                    leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                    title: Text(_cropTips[_selectedCrop]![index]),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Government Schemes Section
            Text(l10n.governmentSchemes, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _schemes.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.account_balance, color: Colors.blue),
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
