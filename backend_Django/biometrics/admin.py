from django.contrib import admin
from .models import BiometricProfile

@admin.register(BiometricProfile)
class BiometricProfileAdmin(admin.ModelAdmin):
    list_display = ("user", "biometric_type", "registered_at")
    list_filter = ("biometric_type",)
    search_fields = ("user__roll_no",)