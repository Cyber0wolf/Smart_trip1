import 'package:flutter_bloc/flutter_bloc.dart';
import 'polls_event.dart';
import 'polls_state.dart';
import '../data/polls_api.dart';
import '../../../core/network/api_client.dart';

class PollsBloc extends Bloc<PollsEvent, PollsState> {
  final PollsApi api;
  int? _tripId;
  List<Map<String, dynamic>> _polls = [];

  PollsBloc(ApiClient apiClient)
      : api = PollsApi(apiClient),
        super(PollsInitial()) {
    on<LoadPolls>(_onLoad);
    on<VoteOnPoll>(_onVote);
  }

  Future<void> _onLoad(LoadPolls e, Emitter<PollsState> emit) async {
    emit(PollsLoading());
    _tripId = e.tripId;
    try {
      _polls = await api.fetchPolls(e.tripId);
      emit(PollsLoaded(List.of(_polls)));
    } catch (_) {
      emit(PollsError('Failed to load polls'));
    }
  }

  Future<void> _onVote(VoteOnPoll e, Emitter<PollsState> emit) async {
    // optimistic: nothing to change locally because API doesn't return counts
    try {
      if (_tripId != null) {
        await api.voteWithTrip(pollId: e.pollId, optionId: e.optionId, tripId: _tripId!);
      } else {
        await api.vote(e.pollId, e.optionId);
      }
      if (_tripId != null) {
        final list = await api.fetchPolls(_tripId!);
        _polls = list;
        emit(PollsLoaded(List.of(_polls)));
      }
    } catch (_) {
      // ignore; in production show error
    }
  }
}
