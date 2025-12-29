from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from trips.models import Trip, TripMember, ItineraryItem, Poll, PollOption


class Command(BaseCommand):
    help = "Seed the database with demo trips, itinerary items, and a sample poll"

    def add_arguments(self, parser):
        parser.add_argument('--count', type=int, default=12, help='Number of trips to create')
        parser.add_argument('--owner-email', type=str, default=None, help='Email of owner user (defaults to first user)')

    def handle(self, *args, **options):
        User = get_user_model()
        owner = None
        if options['owner_email']:
            owner = User.objects.filter(email=options['owner_email']).first()
        if not owner:
            owner = User.objects.first()
        if not owner:
            self.stderr.write(self.style.ERROR('No users exist. Please create a user first.'))
            return

        created = 0
        for i in range(1, options['count'] + 1):
            name = f"Demo Trip {i}"
            trip, was_created = Trip.objects.get_or_create(
                name=name,
                defaults={
                    'description': f'Seeded trip number {i} with demo data',
                    'created_by': owner,
                }
            )
            if was_created:
                TripMember.objects.get_or_create(trip=trip, user=owner)

                # Add 3 itinerary items
                for order in range(1, 4):
                    ItineraryItem.objects.get_or_create(
                        trip=trip,
                        order=order,
                        defaults={
                            'title': f'Activity {order}',
                            'description': f'Description for activity {order}',
                        }
                    )

                # Add a sample poll with two options
                poll = Poll.objects.create(trip=trip, question='Which day works?', created_by=owner)
                PollOption.objects.create(poll=poll, text='Saturday')
                PollOption.objects.create(poll=poll, text='Sunday')

                created += 1

        self.stdout.write(self.style.SUCCESS(f'Seeded {created} new trips (requested {options["count"]}).'))
