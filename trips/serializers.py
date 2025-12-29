from rest_framework import serializers
from .models import Trip, TripMember, ItineraryItem, Poll, PollOption, Vote


class TripSerializer(serializers.ModelSerializer):
    class Meta:
        model = Trip
        fields = '__all__'
        read_only_fields = ('created_by',)


class ItineraryItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = ItineraryItem
        fields = '__all__'


class PollOptionSerializer(serializers.ModelSerializer):
    votes = serializers.SerializerMethodField()
    is_selected = serializers.SerializerMethodField()

    class Meta:
        model = PollOption
        fields = ('id', 'text', 'votes', 'is_selected')

    def get_votes(self, obj):
        return Vote.objects.filter(option=obj).count()

    def get_is_selected(self, obj):
        request = self.context.get("request")
        if not request or not request.user.is_authenticated:
            return False
        return Vote.objects.filter(option=obj, user=request.user).exists()


class PollSerializer(serializers.ModelSerializer):
    options = PollOptionSerializer(many=True, write_only=True)

    class Meta:
        model = Poll
        fields = ("id", "trip", "question", "options")

    def create(self, validated_data):
        options_data = validated_data.pop("options")
        poll = Poll.objects.create(**validated_data)

        for option in options_data:
            PollOption.objects.create(poll=poll, **option)

        return poll

    
from django.contrib.auth import get_user_model
from rest_framework import serializers
from .models import TripMember

User = get_user_model()

class AddCollaboratorSerializer(serializers.Serializer):
    email = serializers.EmailField()

    def validate_email(self, value):
        if not User.objects.filter(email=value).exists():
            raise serializers.ValidationError("User with this email does not exist.")
        return value
    
class VoteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Vote
        fields = ("poll", "option")


class PollListSerializer(serializers.ModelSerializer):
    options = PollOptionSerializer(many=True, read_only=True)

    class Meta:
        model = Poll
        fields = ("id", "question", "options")


class TripMemberSerializer(serializers.ModelSerializer):
    name = serializers.CharField(source="user.username", read_only=True)
    email = serializers.EmailField(source="user.email", read_only=True)

    class Meta:
        model = TripMember
        fields = ("id", "name", "email")
