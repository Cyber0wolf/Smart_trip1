from rest_framework import serializers
from .models import Message

class MessageSerializer(serializers.ModelSerializer):
    sender_email = serializers.EmailField(source="sender.email", read_only=True)

    class Meta:
        model = Message
        fields = ("id", "trip", "sender_email", "content", "created_at")
        read_only_fields = ("sender_email", "created_at", "trip")
