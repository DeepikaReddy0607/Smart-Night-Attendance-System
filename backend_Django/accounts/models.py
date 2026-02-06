import uuid
from django.db import models
from django.contrib.auth.models import AbstractBaseUser,PermissionsMixin,BaseUserManager

class UserManager(BaseUserManager):
    def create_user(self, email, password=None, role="STUDENT", **extra_fields):
        if not email:
            raise ValueError("Email is required")

        email = self.normalize_email(email)
        user = self.model(email=email, role=role, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password):
        user = self.create_user(
            email=email,
            password=password,
            role="WARDEN",
        )
        user.is_staff = True
        user.is_superuser = True
        user.is_active = True
        user.save(using=self._db)
        return user


class User(AbstractBaseUser, PermissionsMixin):
    ROLE_CHOICES = (
        ("STUDENT", "Student"),
        ("WARDEN", "Warden"),
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    email = models.EmailField(unique=True)
    roll_no = models.CharField(max_length=20, unique=True, null=True, blank=True)

    role = models.CharField(max_length=10, choices=ROLE_CHOICES)

    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    USERNAME_FIELD = "roll_no"
    REQUIRED_FIELDS = []

    objects = UserManager()

    def __str__(self):
        return f"{self.email} ({self.role})"


class UserDevice(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="devices")

    device_id = models.CharField(max_length=255, unique=True)
    device_model = models.CharField(max_length=100)
    os_version = models.CharField(max_length=50)

    is_active = models.BooleanField(default=True)
    last_login = models.DateTimeField(auto_now=True)

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.email} - {self.device_id}"
