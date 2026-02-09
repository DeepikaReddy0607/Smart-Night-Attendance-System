from datetime import timedelta
import hashlib
import random

from django.utils import timezone
from django.contrib.auth import authenticate

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework import status

from rest_framework_simplejwt.tokens import RefreshToken

from .serializers import (
    LoginSerializer,
    SendOTPSerializer,
    VerifyOTPSerializer,
    MeSerializer,
)
from .models import User, OTPVerification
from students.models import StudentProfile
from biometrics.models import BiometricProfile

class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user = serializer.validated_data["user"]

        if not user.is_active:
            return Response(
                {"error": "Account disabled"},
                status=status.HTTP_403_FORBIDDEN,
            )

        if user.role == "STUDENT":
            try:
                profile = StudentProfile.objects.get(user=user)
            except StudentProfile.DoesNotExist:
                return Response(
                    {"error": "Student profile missing"},
                    status=status.HTTP_403_FORBIDDEN,
                )

            if profile.registration_stage < 5:
                return Response(
                    {"error": "Registration incomplete"},
                    status=status.HTTP_403_FORBIDDEN,
                )

            if not BiometricProfile.objects.filter(user=user).exists():
                return Response(
                    {"error": "Biometric not registered"},
                    status=status.HTTP_403_FORBIDDEN,
                )

        refresh = RefreshToken.for_user(user)

        return Response(
            {
                "access_token": str(refresh.access_token),
                "refresh_token": str(refresh),
                "role": user.role.lower(),
            },
            status=status.HTTP_200_OK,
        )

class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        # Stateless logout – frontend clears tokens
        return Response(
            {"detail": "Logged out successfully"},
            status=status.HTTP_200_OK,
        )


class MeView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = MeSerializer(request.user)
        return Response(serializer.data)

class SendOTPView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = SendOTPSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        roll_no = serializer.validated_data["roll_no"]
        password = serializer.validated_data["password"]

        otp = str(random.randint(100000, 999999))
        otp_hash = hashlib.sha256(otp.encode()).hexdigest()

        OTPVerification.objects.filter(roll_no=roll_no).delete()

        OTPVerification.objects.create(
            roll_no=roll_no,
            otp_hash=otp_hash,
            temp_password=password,
            expires_at=timezone.now() + timedelta(minutes=5),
        )

        # DEV ONLY (remove in production)
        print(f"[DEV] OTP for {roll_no}: {otp}")

        return Response(
            {"message": "OTP sent successfully"},
            status=status.HTTP_200_OK,
        )

class VerifyOTPView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = VerifyOTPSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        roll_no = serializer.validated_data["roll_no"]
        otp = serializer.validated_data["otp"]

        try:
            record = OTPVerification.objects.get(roll_no=roll_no)
        except OTPVerification.DoesNotExist:
            return Response(
                {"error": "OTP not found"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if record.expires_at < timezone.now():
            record.delete()
            return Response(
                {"error": "OTP expired"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        otp_hash = hashlib.sha256(otp.encode()).hexdigest()
        if otp_hash != record.otp_hash:
            return Response(
                {"error": "Invalid OTP"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        password = record.temp_password
        if not password:
            return Response(
                {"error": "Registration session expired"},
                status=status.HTTP_400_BAD_REQUEST,
            )
        
        # CREATE USER
        user = User.objects.create_user(
            roll_no=roll_no,
            password=password,
            role="STUDENT",
        )
        user.is_active = False
        user.save()

        # CREATE STUDENT PROFILE
        StudentProfile.objects.create(
            user=user,
            registration_stage=2,  # OTP verified
        )

        record.delete()

        return Response(
            {"message": "Registration successful"},
            status=status.HTTP_201_CREATED,
        )
