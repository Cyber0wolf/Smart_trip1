from rest_framework.permissions import BasePermission
from trips.models import TripMember

class IsTripMember(BasePermission):
    def has_permission(self, request, view):
        trip_id = view.kwargs.get("trip_id")
        if not trip_id:
            # Fallback: read from request data (e.g., POST body for polls)
            trip_id = request.data.get("trip")
            if not trip_id:
                return False

        return TripMember.objects.filter(
            trip_id=trip_id,
            user=request.user
        ).exists()
