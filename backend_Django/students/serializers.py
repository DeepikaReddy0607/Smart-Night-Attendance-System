from rest_framework import serializers
from .models import StudentProfile


class HostelAssignmentSerializer(serializers.Serializer):
    hostel = serializers.CharField(max_length=100)
    block = serializers.CharField(max_length=50)
    room_number = serializers.CharField(max_length=20)
