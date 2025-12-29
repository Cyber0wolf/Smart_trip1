from rest_framework.generics import ListCreateAPIView
from rest_framework.permissions import IsAuthenticated
from .models import Message
from .serializers import MessageSerializer

class TripMessageListCreateView(ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = MessageSerializer

    def get_queryset(self):
        return Message.objects.filter(
            trip_id=self.kwargs["trip_id"]
        ).order_by("-created_at")

    def perform_create(self, serializer):
        serializer.save(
            sender=self.request.user,
            trip_id=self.kwargs["trip_id"]
        )
