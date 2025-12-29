import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import '../data/chat_api.dart';
import '../../../core/network/api_client.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatApi api;
  int? _tripId;
  List<Map<String, dynamic>> _messages = [];

  ChatBloc(ApiClient apiClient)
      : api = ChatApi(apiClient),
        super(ChatInitial()) {
    on<LoadChat>(_onLoad);
    on<SendChatMessage>(_onSend);
    on<PollChat>(_onPoll);
  }

  Future<void> _onLoad(LoadChat e, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    _tripId = e.tripId;
    try {
      _messages = await api.fetchMessages(e.tripId);
      emit(ChatLoaded(List.of(_messages)));
    } catch (_) {
      emit(ChatError('Failed to load chat'));
    }
  }

  Future<void> _onSend(SendChatMessage e, Emitter<ChatState> emit) async {
    if (_tripId == null) return;
    final temp = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'content': e.content,
      'sender_email': 'me',
      'created_at': DateTime.now().toIso8601String(),
    };
    _messages = [..._messages, temp];
    emit(ChatLoaded(List.of(_messages)));
    try {
      final saved = await api.sendMessage(_tripId!, e.content);
      // replace temp with saved by id not critical; list already shows latest
    } catch (_) {
      // revert optimistic message, notify error, then restore view
      _messages.removeWhere((m) => m['id'] == temp['id']);
      emit(ChatError('Failed to send message'));
      emit(ChatLoaded(List.of(_messages)));
    }
  }

  Future<void> _onPoll(PollChat e, Emitter<ChatState> emit) async {
    if (_tripId == null) return;
    try {
      final latest = await api.fetchMessages(_tripId!);
      if (latest.length != _messages.length) {
        _messages = latest;
        emit(ChatLoaded(List.of(_messages)));
      } else if (_messages.isEmpty == false && latest.isNotEmpty) {
        final lastA = _messages.last['id'];
        final lastB = latest.last['id'];
        if (lastA != lastB) {
          _messages = latest;
          emit(ChatLoaded(List.of(_messages)));
        }
      }
    } catch (_) {
      // silent
    }
  }
}
