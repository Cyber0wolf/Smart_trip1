from django.contrib import admin

# Register your models here.
from .models import *
admin.site.register(Trip)
admin.site.register(TripMember)
admin.site.register(ItineraryItem)
admin.site.register(Poll)
admin.site.register(PollOption)
admin.site.register(Vote)