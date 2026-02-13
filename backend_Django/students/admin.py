from django.contrib import admin
from .models import StudentProfile

@admin.register(StudentProfile)
class StudentProfileAdmin(admin.ModelAdmin):
    list_display = (
        "user",
        "hostel",
        "block",
        "room_number",
    )
    list_filter = ("hostel",)
