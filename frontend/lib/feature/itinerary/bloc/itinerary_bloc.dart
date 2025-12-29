import 'package:flutter_bloc/flutter_bloc.dart';
import 'itinerary_event.dart';
import 'itinerary_state.dart';
import '../data/itinerary_api.dart';

class ItineraryBloc extends Bloc<ItineraryEvent, ItineraryState> {
  final ItineraryApi api;
  int? _tripId;
  List<Map<String, dynamic>> _items = [];

  ItineraryBloc(this.api) : super(ItineraryInitial()) {
    on<LoadItinerary>(_onLoad);
    on<ReorderItinerary>(_onReorder);
  }

  Future<void> _onLoad(LoadItinerary e, Emitter<ItineraryState> emit) async {
    emit(ItineraryLoading());
    _tripId = e.tripId;
    try {
      _items = await api.fetchItinerary(e.tripId);
      emit(ItineraryLoaded(List.of(_items)));
    } catch (_) {
      emit(ItineraryError('Failed to load itinerary'));
    }
  }

  Future<void> _onReorder(ReorderItinerary e, Emitter<ItineraryState> emit) async {
    if (_items.isEmpty) return;
    int oldIndex = e.oldIndex;
    int newIndex = e.newIndex;
    if (newIndex > oldIndex) newIndex -= 1;

    final item = _items.removeAt(oldIndex);
    _items.insert(newIndex, item);

    // update order field locally
    for (int i = 0; i < _items.length; i++) {
      _items[i]['order'] = i;
    }

    emit(ItineraryLoaded(List.of(_items)));

    // persist locally (offline-first); backend reorder can be added later
    if (_tripId != null) {
      await api.saveLocal(_tripId!, _items);
    }
  }
}
