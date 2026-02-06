from django.contrib import admin
from .models import User, UserDevice


@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ("email", "role", "is_active", "is_staff", "created_at")
    list_filter = ("role", "is_active")
    search_fields = ("email", "roll_no")
    ordering = ("-created_at",)


@admin.register(UserDevice)
class UserDeviceAdmin(admin.ModelAdmin):
    list_display = ("user", "device_id", "is_active", "last_login")
    list_filter = ("is_active",)
    search_fields = ("device_id", "user__email")
