abstract class ChatEvent {}

class LoadChat extends ChatEvent {
  final int tripId;
  LoadChat(this.tripId);
}

class SendChatMessage extends ChatEvent {
  final String content;
  SendChatMessage(this.content);
}

class PollChat extends ChatEvent {}
