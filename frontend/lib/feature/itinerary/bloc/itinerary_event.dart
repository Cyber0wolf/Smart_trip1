abstract class ItineraryEvent {}

class LoadItinerary extends ItineraryEvent {
  final int tripId;
  LoadItinerary(this.tripId);
}

class ReorderItinerary extends ItineraryEvent {
  final int oldIndex;
  final int newIndex;
  ReorderItinerary(this.oldIndex, this.newIndex);
}
