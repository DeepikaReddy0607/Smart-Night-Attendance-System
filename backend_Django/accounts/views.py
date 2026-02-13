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

class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user = serializer.validated_data["user"]

        if user.role == "STUDENT":
            try:
                StudentProfile.objects.get(user=user)
            except StudentProfile.DoesNotExist:
                return Response(
                    {"error": "Student profile missing"},
                    status=status.HTTP_403_FORBIDDEN,
                )

        # Generate LOGIN OTP
        otp = str(random.randint(100000, 999999))
        otp_hash = hashlib.sha256(otp.encode()).hexdigest()

        OTPVerification.objects.filter(
            roll_no=user.roll_no,
            purpose="LOGIN"
        ).delete()

        OTPVerification.objects.create(
            roll_no=user.roll_no,
            otp_hash=otp_hash,
            purpose="LOGIN",
            expires_at=timezone.now() + timedelta(minutes=5),
        )

        print(f"[LOGIN OTP] {user.roll_no}: {otp}")

        return Response(
            {"message": "OTP sent"},
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

        # 🔥 Student must already exist (allocated by admin)
        try:
            user = User.objects.get(roll_no=roll_no, role="STUDENT")
        except User.DoesNotExist:
            return Response(
                {"error": "Student not allocated by admin"},
                status=status.HTTP_403_FORBIDDEN,
            )

        # If already active, block OTP
        if user.is_active:
            return Response(
                {"error": "Account already activated"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Generate OTP
        otp = str(random.randint(100000, 999999))
        otp_hash = hashlib.sha256(otp.encode()).hexdigest()

        OTPVerification.objects.filter(roll_no=roll_no, purpose="ACTIVATION").delete()

        OTPVerification.objects.create(
            roll_no=roll_no,
            otp_hash=otp_hash,
            purpose="ACTIVATION",
            temp_password=password,
            expires_at=timezone.now() + timedelta(minutes=5),
        )

        # DEV ONLY
        print(f"[DEV OTP] {roll_no}: {otp}")

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
        purpose = serializer.validated_data["purpose"]

        try:
            record = OTPVerification.objects.get(
                roll_no=roll_no,
                purpose=purpose
            )
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

        try:
            user = User.objects.get(roll_no=roll_no)
        except User.DoesNotExist:
            return Response(
                {"error": "User not found"},
                status=status.HTTP_404_NOT_FOUND,
            )

        # 🔥 ACTIVATION FLOW
        if purpose == "ACTIVATION":

            if user.is_active:
                return Response(
                    {"error": "Account already activated"},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if not record.temp_password:
                return Response(
                    {"error": "Registration session expired"},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            user.set_password(record.temp_password)
            user.is_active = True
            user.save()

        # 🔥 LOGIN FLOW
        elif purpose == "LOGIN":

            if not user.is_active:
                return Response(
                    {"error": "Account not activated"},
                    status=status.HTTP_403_FORBIDDEN,
                )

        record.delete()

        refresh = RefreshToken.for_user(user)

        return Response(
            {
                "access_token": str(refresh.access_token),
                "refresh_token": str(refresh),
                "role": user.role.lower(),
            },
            status=status.HTTP_200_OK,
        )
