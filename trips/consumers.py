import json
from channels.generic.websocket import AsyncWebsocketConsumer
from django.utils import timezone
from asgiref.sync import sync_to_async
from trips.models import Trip, TripMember
from chat.models import Message


class ChatConsumer(AsyncWebsocketConsumer):

    async def connect(self):
        self.trip_id = self.scope["url_route"]["kwargs"]["trip_id"]
        self.group_name = f"trip_chat_{self.trip_id}"

        user = self.scope.get("user")

        # 🔐 JWT / auth check
        if not user or not user.is_authenticated:
            await self.close(code=4001)
            return

        # 🔐 Trip membership check
        if not await self.is_trip_member(user, self.trip_id):
            await self.close(code=4003)
            return

        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.group_name, self.channel_name)

    async def receive(self, text_data):
        try:
            data = json.loads(text_data)
        except json.JSONDecodeError:
            return  # silently ignore bad payloads

        content = data.get("message")
        if not content:
            return

        user = self.scope["user"]

        message = await self.save_message(user, self.trip_id, content)

        await self.channel_layer.group_send(
            self.group_name,
            {
                "type": "broadcast_message",
                "payload": {
                    "type": "message",
                    "trip_id": self.trip_id,
                    "sender": user.email,
                    "content": message.content,
                    "created_at": message.created_at.isoformat(),
                }
            }
        )

    async def broadcast_message(self, event):
        await self.send(text_data=json.dumps(event["payload"]))

    # ===== DB helpers =====

    @sync_to_async
    def is_trip_member(self, user, trip_id):
        return TripMember.objects.filter(
            trip_id=trip_id,
            user=user
        ).exists()

    @sync_to_async
    def save_message(self, user, trip_id, content):
        trip = Trip.objects.get(id=trip_id)
        return Message.objects.create(
            trip=trip,
            sender=user,
            content=content,
            created_at=timezone.now()
        )
