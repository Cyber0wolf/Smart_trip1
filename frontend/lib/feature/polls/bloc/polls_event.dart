abstract class PollsEvent {}

class LoadPolls extends PollsEvent {
  final int tripId;
  LoadPolls(this.tripId);
}

class VoteOnPoll extends PollsEvent {
  final int pollId;
  final int optionId;
  VoteOnPoll(this.pollId, this.optionId);
}
