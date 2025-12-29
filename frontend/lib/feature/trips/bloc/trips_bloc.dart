import 'package:flutter_bloc/flutter_bloc.dart';
import 'trips_event.dart';
import 'trips_state.dart';
import '../data/trips_api.dart';

class TripsBloc extends Bloc<TripsEvent, TripsState> {
  final TripsApi tripsApi;

  TripsBloc(this.tripsApi) : super(TripsInitial()) {
    on<FetchTrips>(_onFetchTrips);
    on<FetchExploreTrips>(_onFetchExplore);
    on<CreateTrip>(_onCreateTrip);
  }

  Future<void> _onFetchTrips(
    FetchTrips event,
    Emitter<TripsState> emit,
  ) async {
    emit(TripsLoading());
    try {
      final trips = await tripsApi.fetchTrips();
      emit(TripsLoaded(trips));
    } catch (_) {
      emit(TripsError('Failed to load trips'));
    }
  }

  Future<void> _onCreateTrip(
    CreateTrip event,
    Emitter<TripsState> emit,
  ) async {
    try {
      await tripsApi.createTrip(event.name);
      add(FetchTrips());
    } catch (_) {
      emit(TripsError('Failed to create trip'));
    }
  }

  Future<void> _onFetchExplore(
    FetchExploreTrips event,
    Emitter<TripsState> emit,
  ) async {
    emit(TripsLoading());
    try {
      final trips = await tripsApi.fetchExploreTrips();
      emit(TripsLoaded(trips));
    } catch (_) {
      emit(TripsError('Failed to load trips'));
    }
  }
}
