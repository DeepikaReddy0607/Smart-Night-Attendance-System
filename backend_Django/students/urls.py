from django.urls import path
from .views import AssignHostelView

urlpatterns = [
    path("assign-hostel/", AssignHostelView.as_view()),
]
