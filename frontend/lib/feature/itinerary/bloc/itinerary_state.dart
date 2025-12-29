abstract class ItineraryState {}

class ItineraryInitial extends ItineraryState {}

class ItineraryLoading extends ItineraryState {}

class ItineraryLoaded extends ItineraryState {
  final List<Map<String, dynamic>> items;
  ItineraryLoaded(this.items);
}

class ItineraryError extends ItineraryState {
  final String message;
  ItineraryError(this.message);
}
