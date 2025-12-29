from rest_framework.generics import ListCreateAPIView, CreateAPIView, ListAPIView, GenericAPIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.exceptions import ValidationError
from drf_spectacular.utils import extend_schema
from django.shortcuts import get_object_or_404
from django.core.mail import send_mail
from django.conf import settings
from django.contrib.auth import get_user_model
from django.db import transaction

from .models import (
    Trip,
    TripMember,
    ItineraryItem,
    Poll,
    PollOption,
    Vote,
)
from .serializers import (
    TripSerializer,
    ItineraryItemSerializer,
    AddCollaboratorSerializer,
    PollSerializer,
    VoteSerializer,
    PollListSerializer,
    TripMemberSerializer,
)
from .permissions import IsTripMember



class TripListCreateView(ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = TripSerializer

    def get_queryset(self):
        explore = self.request.query_params.get('explore')
        if explore and explore.lower() in ('1', 'true', 'yes'):
            return Trip.objects.exclude(members__user=self.request.user)
        return Trip.objects.filter(members__user=self.request.user)

    def perform_create(self, serializer):
        trip = serializer.save(created_by=self.request.user)
        TripMember.objects.create(trip=trip, user=self.request.user)



class TripExploreListView(ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = TripSerializer

    def get_queryset(self):
        # Trips where current user is NOT a member
        return Trip.objects.exclude(members__user=self.request.user)


class ItineraryListCreateView(ListCreateAPIView):
    permission_classes = [IsAuthenticated, IsTripMember]
    serializer_class = ItineraryItemSerializer

    def get_queryset(self):
        return ItineraryItem.objects.filter(trip_id=self.kwargs['trip_id'])

    def perform_create(self, serializer):
        serializer.save(trip_id=self.kwargs['trip_id'])


class JoinTripView(CreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = TripSerializer

    def post(self, request, trip_id):
        trip = get_object_or_404(Trip, id=trip_id)
        TripMember.objects.get_or_create(trip=trip, user=request.user)
        return Response({"message": "Joined"}, status=200)


class LeaveTripView(CreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = TripSerializer

    def post(self, request, trip_id):
        trip = get_object_or_404(Trip, id=trip_id)
        TripMember.objects.filter(trip=trip, user=request.user).delete()
        return Response({"message": "Left"}, status=200)


User = get_user_model()


class AddCollaboratorView(GenericAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = AddCollaboratorSerializer

    def post(self, request, trip_id):
        trip = get_object_or_404(Trip, id=trip_id)

        if trip.created_by != request.user:
            return Response(
                {"detail": "Only trip owner can invite collaborators."},
                status=403
            )

        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user = User.objects.get(email=serializer.validated_data["email"])
        TripMember.objects.get_or_create(trip=trip, user=user)

        send_mail(
            subject="Trip Invitation",
            message=f"You have been added to the trip: {trip.name}",
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[user.email],
            fail_silently=True,
        )

        return Response({"message": "Collaborator added successfully"}, status=200)



class PollCreateView(CreateAPIView):
    permission_classes = [IsAuthenticated, IsTripMember]
    serializer_class = PollSerializer

    @transaction.atomic
    def create(self, request, *args, **kwargs):
        """
        Custom create to avoid any serializer/representation quirks that were
        causing the frontend to see an error even though the poll was created.
        """
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        poll = serializer.save(created_by=request.user)

        # Return a simplified representation that matches what the list endpoint uses.
        output = PollListSerializer(poll).data
        return Response(output, status=201)


class PollListView(ListAPIView):
    permission_classes = [IsAuthenticated, IsTripMember]
    serializer_class = PollListSerializer

    def get_queryset(self):
        return Poll.objects.filter(trip_id=self.kwargs["trip_id"])


class VoteCreateView(CreateAPIView):
    permission_classes = [IsAuthenticated, IsTripMember]
    serializer_class = VoteSerializer

    def perform_create(self, serializer):
        poll = serializer.validated_data["poll"]

        if Vote.objects.filter(poll=poll, user=self.request.user).exists():
            raise ValidationError("You have already voted in this poll.")

        serializer.save(user=self.request.user)


class TripMembersListView(ListAPIView):
    permission_classes = [IsAuthenticated, IsTripMember]
    serializer_class = TripMemberSerializer

    def get_queryset(self):
        return TripMember.objects.filter(trip_id=self.kwargs["trip_id"])
