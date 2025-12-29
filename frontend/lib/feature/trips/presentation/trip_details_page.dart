import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../chat/presentation/chat_tab.dart';
import '../../polls/presentation/polls_tab.dart';
import '../bloc/trips_bloc.dart';
import '../bloc/trips_event.dart';
import '../data/trips_api.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/theme/app_theme.dart';

class TripDetailsPage extends StatelessWidget {
  final Map<String, dynamic> trip;

  const TripDetailsPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            trip['name'] ?? 'Trip Details',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.info_outline), text: "Details"),
              Tab(icon: Icon(Icons.chat_bubble_outline), text: "Chat"),
              Tab(icon: Icon(Icons.poll_outlined), text: "Polls"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DetailsTab(trip: trip),
            ChatTab(tripId: trip['id'] as int),
            PollsTab(tripId: trip['id'] as int),
          ],
        ),
      ),
    );
  }
}

/* ---------------- DETAILS TAB ---------------- */

class _DetailsTab extends StatelessWidget {
  final Map<String, dynamic> trip;

  const _DetailsTab({required this.trip});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.flight_takeoff_rounded,
                          color: Colors.white,
                          size: 28,
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
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Trip ID: ${trip['id']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Description Section
          if (trip['description'] != null && trip['description'].toString().isNotEmpty) ...[
            Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  trip['description'],
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Info Section
          Text(
            'Trip Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Trip Details',
                    value: 'Coming soon',
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Destinations',
                    value: 'To be added',
                  ),
                  const Divider(height: 24),
                  _MembersRow(tripId: trip['id'] as int),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Leave Trip Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('Leave Trip?'),
                    content: const Text('Are you sure you want to leave this trip? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorColor,
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Leave'),
                      ),
                    ],
                  ),
                );
                if (confirm != true) return;
                try {
                  await TripsApi(ApiClient()).leaveTrip(trip['id'] as int);
                  if (context.mounted) {
                    context.read<TripsBloc>().add(FetchTrips());
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Left trip successfully')),
                    );
                  }
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to leave trip')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Leave Trip'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MembersRow extends StatefulWidget {
  final int tripId;

  const _MembersRow({required this.tripId});

  @override
  State<_MembersRow> createState() => _MembersRowState();
}

class _MembersRowState extends State<_MembersRow> {
  String _value = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final api = TripsApi(ApiClient());
      final members = await api.fetchTripMembers(widget.tripId);
      if (!mounted) return;
      if (members.isEmpty) {
        setState(() {
          _value = 'Only you for now';
        });
        return;
      }

      final names = members
          .map<String>(
            (m) => (m['name'] as String?)?.trim().isNotEmpty == true
                ? m['name'] as String
                : (m['email'] as String? ?? ''),
          )
          .where((n) => n.isNotEmpty)
          .toList();

      setState(() {
        if (names.isEmpty) {
          _value = 'Members unavailable';
        } else if (names.length <= 3) {
          _value = names.join(', ');
        } else {
          final firstThree = names.take(3).join(', ');
          _value = '$firstThree +${names.length - 3} more';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        // Graceful fallback – for demo purposes, assume just current user.
        _value = 'Only you for now';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _InfoRow(
      icon: Icons.people_outline,
      label: 'Members',
      value: _value,
    );
  }
}

/* ---------------- CHAT TAB ---------------- */

class _ChatTab extends StatelessWidget {
  const _ChatTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Chat feature coming next 🚀",
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}

/* ---------------- POLLS TAB ---------------- */

class _PollsTab extends StatelessWidget {
  const _PollsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Polls feature coming next 📊",
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
