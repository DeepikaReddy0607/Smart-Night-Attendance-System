from rest_framework import serializers
from django.contrib.auth import authenticate
from .models import User, UserDevice


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    device_id = serializers.CharField()
    device_model = serializers.CharField()
    os_version = serializers.CharField()

    def validate(self, data):
        user = authenticate(
            email=data["email"],
            password=data["password"]
        )

        if not user:
            raise serializers.ValidationError("Invalid credentials")

        if not user.is_active:
            raise serializers.ValidationError("Account inactive")

        data["user"] = user
        return data


class MeSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ("id", "email", "roll_no", "role")


class UserDeviceSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserDevice
        fields = ("device_id", "device_model", "os_version", "is_active")
