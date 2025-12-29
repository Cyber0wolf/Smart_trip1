import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/itinerary_bloc.dart';
import '../bloc/itinerary_event.dart';
import '../bloc/itinerary_state.dart';
import '../data/itinerary_api.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/theme/app_theme.dart';

class ItineraryTab extends StatelessWidget {
  final int tripId;
  const ItineraryTab({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ItineraryBloc(ItineraryApi(ApiClient()))..add(LoadItinerary(tripId)),
      child: BlocBuilder<ItineraryBloc, ItineraryState>(
        builder: (context, state) {
          if (state is ItineraryLoading || state is ItineraryInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ItineraryLoaded) {
            final items = state.items;
            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 64,
                      color: AppTheme.textLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No itinerary items',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add items to plan your trip',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(16),
              child: ReorderableListView.builder(
                itemCount: items.length,
                onReorder: (oldIndex, newIndex) {
                  context.read<ItineraryBloc>().add(ReorderItinerary(oldIndex, newIndex));
                },
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _ItineraryItem(
                    key: ValueKey('itinerary_${item['id']}_${item['order']}'),
                    item: item,
                    index: index,
                  );
                },
              ),
            );
          }
          if (state is ItineraryError) {
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
    );
  }
}

class _ItineraryItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;

  const _ItineraryItem({
    required Key key,
    required this.item,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          item['title'] ?? 'Item ${item['order']}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          'Order: ${item['order']}',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.drag_handle,
          color: AppTheme.textLight,
        ),
      ),
    );
  }
}
