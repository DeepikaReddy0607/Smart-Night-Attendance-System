from django.db import models
from accounts.models import User

class StudentProfile(models.Model):
    REGISTRATION_STAGES = (
        (0, "Not Started"),
        (1, "Identity Verified"),
        (2, "OTP Verified"),
        (3, "Hostel Assigned"),
        (4, "Biometric Registered"),
        (5, "Registration Complete"),
    )

    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name="student_profile"
    )

    registration_stage = models.PositiveSmallIntegerField(
        choices=REGISTRATION_STAGES,
        default=0
    )

    # Physical binding (critical for geo-fencing)
    hostel = models.CharField(max_length=100)
    block = models.CharField(max_length=50)
    room_number = models.CharField(max_length=20)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.roll_no} | {self.hostel}-{self.block}"

