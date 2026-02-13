from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status

from accounts.models import User
from .models import StudentProfile

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status

from accounts.models import User
from .models import StudentProfile


class AssignHostelView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        # 🔒 Only admin/warden should do this
        if request.user.role not in ["ADMIN", "WARDEN"]:
            return Response(
                {"error": "Permission denied"},
                status=status.HTTP_403_FORBIDDEN,
            )

        roll_no = request.data.get("roll_no")
        hostel = request.data.get("hostel")
        block = request.data.get("block")
        room_number = request.data.get("room_number")

        if not all([roll_no, hostel, block, room_number]):
            return Response(
                {"error": "All fields are required"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            user = User.objects.get(roll_no=roll_no, role="STUDENT")
        except User.DoesNotExist:
            return Response(
                {"error": "Student not found"},
                status=status.HTTP_404_NOT_FOUND,
            )

        # Create profile if not exists
        profile, created = StudentProfile.objects.get_or_create(user=user)

        profile.hostel = hostel
        profile.block = block
        profile.room_number = room_number
        profile.save()

        return Response(
            {"message": "Hostel assigned successfully"},
            status=status.HTTP_200_OK,
        )
