from django.db import models
from accounts.models import User

class BiometricProfile(models.Model):
    BIOMETRIC_TYPES = (
        ("FACE", "Face"),
        ("IRIS", "Iris"),
    )

    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name="biometric_profile"
    )

    biometric_type = models.CharField(
        max_length=10,
        choices=BIOMETRIC_TYPES
    )

    biometric_template = models.TextField(
        help_text="Encrypted biometric template"
    )

    registered_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.roll_no} - {self.biometric_type}"
