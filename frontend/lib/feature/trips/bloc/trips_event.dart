abstract class TripsEvent {}

class FetchTrips extends TripsEvent {}

class FetchExploreTrips extends TripsEvent {}

class CreateTrip extends TripsEvent {
  final String name;
  CreateTrip(this.name);
}
