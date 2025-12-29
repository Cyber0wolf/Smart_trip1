abstract class PollsState {}

class PollsInitial extends PollsState {}

class PollsLoading extends PollsState {}

class PollsLoaded extends PollsState {
  final List<Map<String, dynamic>> polls;
  PollsLoaded(this.polls);
}

class PollsError extends PollsState {
  final String message;
  PollsError(this.message);
}
