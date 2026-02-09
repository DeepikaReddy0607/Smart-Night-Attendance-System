from django.urls import path
from .views import RegisterBiometricView

urlpatterns = [
    path("register/", RegisterBiometricView.as_view()),
]
