from rest_framework import serializers
from django.contrib.auth import authenticate
from .models import User


class LoginSerializer(serializers.Serializer):
    roll_no = serializers.CharField(max_length=20)
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        user = authenticate(
            roll_no=data["roll_no"],
            password=data["password"]
        )

        if not user:
            raise serializers.ValidationError("Invalid credentials")

        data["user"] = user
        return data


class MeSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ("roll_no", "role")


class SendOTPSerializer(serializers.Serializer):
    roll_no = serializers.CharField(max_length=20)
    password = serializers.CharField()

class VerifyOTPSerializer(serializers.Serializer):
    roll_no = serializers.CharField(max_length=20)
    otp = serializers.CharField(max_length=6)
    purpose = serializers.ChoiceField(choices=["ACTIVATION","LOGIN"])
