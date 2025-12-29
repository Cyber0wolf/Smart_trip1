import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../trips/bloc/trips_bloc.dart';
import '../../trips/bloc/trips_event.dart';
import '../../trips/bloc/trips_state.dart';
import '../../trips/data/trips_api.dart';
import '../../trips/presentation/trips_page.dart';
import '../../profile/presentation/account_page.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Start on "My Trips" instead of "Explore" so reloads land on trips.
  int _currentIndex = 1;
  late final TripsBloc _tripsBloc;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    _tripsBloc = TripsBloc(TripsApi(apiClient))..add(FetchTrips());
  }

  @override
  void dispose() {
    _tripsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _tripsBloc,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            _AllTripsTab(),
            TripsPage(), // My Trips (same endpoint, but separate tab)
            AccountPage(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_rounded),
                activeIcon: Icon(Icons.explore),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.luggage_outlined),
                activeIcon: Icon(Icons.luggage),
                label: 'My Trips',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllTripsTab extends StatelessWidget {
  const _AllTripsTab();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TripsBloc(TripsApi(ApiClient()))..add(FetchExploreTrips()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Explore Trips'),
          elevation: 0,
        ),
        body: BlocBuilder<TripsBloc, TripsState>(
          builder: (context, state) {
            if (state is TripsLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state is TripsLoaded) {
              final trips = state.trips;
              if (trips.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.explore_outlined,
                        size: 64,
                        color: AppTheme.textLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No trips available',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: trips.length,
                itemBuilder: (_, index) {
                  final trip = trips[index];
                  return _TripCard(
                    trip: trip,
                    onJoin: () async {
                      try {
                        await TripsApi(ApiClient()).joinTrip(trip['id'] as int);
                        if (context.mounted) {
                          context.read<TripsBloc>().add(FetchExploreTrips());
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Joined trip successfully!')),
                          );
                        }
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to join trip')),
                          );
                        }
                      }
                    },
                  );
                },
              );
            }
            if (state is TripsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final Map<String, dynamic> trip;
  final VoidCallback onJoin;

  const _TripCard({
    required this.trip,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onJoin,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.flight_takeoff_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip['name'] ?? 'Trip',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (trip['description'] != null && trip['description'].toString().isNotEmpty)
                          const SizedBox(height: 4),
                        if (trip['description'] != null && trip['description'].toString().isNotEmpty)
                          Text(
                            trip['description'],
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onJoin,
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: const Text('Join Trip'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
