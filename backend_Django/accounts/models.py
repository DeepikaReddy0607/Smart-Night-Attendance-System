import uuid
from django.db import models
from django.contrib.auth.models import AbstractBaseUser,PermissionsMixin,BaseUserManager
class UserManager(BaseUserManager):
    def create_user(self, roll_no, password=None, role="STUDENT", **extra_fields):
        if not roll_no:
            raise ValueError("Roll number is required")

        user = self.model(
            roll_no=roll_no,
            role=role,
            **extra_fields
        )
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, roll_no, password):
        user = self.create_user(
            roll_no=roll_no,
            password=password,
            role="WARDEN",
        )
        user.is_staff = True
        user.is_superuser = True
        user.save(using=self._db)
        return user

class User(AbstractBaseUser, PermissionsMixin):
    ROLE_CHOICES = (
        ("STUDENT", "Student"),
        ("WARDEN", "Warden"),
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    roll_no = models.CharField(max_length=20, unique=True)

    role = models.CharField(max_length=10, choices=ROLE_CHOICES)

    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    USERNAME_FIELD = "roll_no"
    REQUIRED_FIELDS = []

    objects = UserManager()

    def __str__(self):
        return f"{self.roll_no} ({self.role})"

class OTPVerification(models.Model):
    roll_no = models.CharField(max_length=20)

    otp_hash = models.CharField(max_length=128)
    temp_password = models.CharField(max_length=128)
    expires_at = models.DateTimeField()

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"OTP for {self.roll_no}"

class WardenProfile(models.Model):
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name="warden_profile"
    )

    designation = models.CharField(
        max_length=100,
        help_text="e.g. Caretaker, Warden, Chief Warden"
    )

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.roll_no} - {self.designation}"
