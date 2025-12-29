from django.urls import path
from .views import (
    TripListCreateView,
    ItineraryListCreateView,
    PollCreateView,
    VoteCreateView,
    PollListView,
    TripExploreListView,
    JoinTripView,
    LeaveTripView,
    TripMembersListView,
)
from .views import AddCollaboratorView

urlpatterns = [
    path('trips/', TripListCreateView.as_view()),
    path('trips/explore/', TripExploreListView.as_view()),
    path('trips/<int:trip_id>/itinerary/', ItineraryListCreateView.as_view()),
    path('trips/<int:trip_id>/join/', JoinTripView.as_view()),
    path('trips/<int:trip_id>/leave/', LeaveTripView.as_view()),
    path("trips/<int:trip_id>/invite/", AddCollaboratorView.as_view()),
    path("trips/<int:trip_id>/members/", TripMembersListView.as_view()),
    path("trips/<int:trip_id>/polls/", PollListView.as_view()),
    path("polls/", PollCreateView.as_view()),
    path("polls/vote/", VoteCreateView.as_view())
]
