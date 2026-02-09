from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from rest_framework import status

from accounts.models import User
from .models import StudentProfile


class AssignHostelView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
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
            profile = StudentProfile.objects.get(user=user)
        except (User.DoesNotExist, StudentProfile.DoesNotExist):
            return Response(
                {"error": "Student not found"},
                status=status.HTTP_404_NOT_FOUND,
            )

        # 🔒 SAFETY CHECK
        if user.is_active:
            return Response(
                {"error": "Registration already completed"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # SAVE HOSTEL DETAILS
        profile.hostel = hostel
        profile.block = block
        profile.room_number = room_number
        profile.registration_stage = 3
        profile.save()

        return Response(
            {"message": "Hostel details saved"},
            status=status.HTTP_200_OK,
        )
