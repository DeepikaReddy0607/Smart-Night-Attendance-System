from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework import status

from rest_framework_simplejwt.tokens import RefreshToken

from .serializers import LoginSerializer, MeSerializer
from .models import UserDevice


class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user = serializer.validated_data["user"]

        device_id = serializer.validated_data["device_id"]
        device_model = serializer.validated_data["device_model"]
        os_version = serializer.validated_data["os_version"]

        # 🔒 Device enforcement (students only)
        if user.role == "STUDENT":
            UserDevice.objects.filter(
                user=user,
                is_active=True
            ).update(is_active=False)

        UserDevice.objects.update_or_create(
            device_id=device_id,
            defaults={
                "user": user,
                "device_model": device_model,
                "os_version": os_version,
                "is_active": True,
            },
        )

        refresh = RefreshToken.for_user(user)

        return Response(
            {
                "access": str(refresh.access_token),
                "refresh": str(refresh),
                "role": user.role,
            },
            status=status.HTTP_200_OK,
        )


class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        UserDevice.objects.filter(
            user=request.user,
            is_active=True
        ).update(is_active=False)

        return Response(
            {"detail": "Logged out successfully"},
            status=status.HTTP_200_OK,
        )


class MeView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = MeSerializer(request.user)
        return Response(serializer.data)
