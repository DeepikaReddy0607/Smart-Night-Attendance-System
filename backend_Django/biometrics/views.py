from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from .models import BiometricProfile
from .serializers import BiometricRegisterSerializer
from students.models import StudentProfile


class RegisterBiometricView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = BiometricRegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user = request.user

        if user.role != "STUDENT":
            return Response(
                {"error": "Only students can register biometrics"},
                status=status.HTTP_403_FORBIDDEN,
            )

        try:
            profile = StudentProfile.objects.get(user=user)
        except StudentProfile.DoesNotExist:
            return Response(
                {"error": "Student profile not found"},
                status=status.HTTP_404_NOT_FOUND,
            )

        if profile.registration_stage < 3:
            return Response(
                {"error": "Hostel assignment required"},
                status=status.HTTP_403_FORBIDDEN,
            )

        if BiometricProfile.objects.filter(user=user).exists():
            return Response(
                {"error": "Biometric already registered"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        BiometricProfile.objects.create(
            user=user,
            biometric_type=serializer.validated_data["biometric_type"],
            biometric_template=serializer.validated_data["biometric_template"],
        )

        profile.registration_stage = 4
        profile.save()

        return Response(
            {"message": "Biometric registered successfully"},
            status=status.HTTP_201_CREATED,
        )
