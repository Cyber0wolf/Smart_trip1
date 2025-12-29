from django.urls import path 
from .views import TripMessageListCreateView

urlpatterns = [
    path("trips/<int:trip_id>/messages/", TripMessageListCreateView.as_view()),

]
