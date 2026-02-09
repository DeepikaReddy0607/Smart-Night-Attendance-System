from django.urls import path
from .views import LoginView, LogoutView, MeView, SendOTPView, VerifyOTPView

urlpatterns = [
    path("login/", LoginView.as_view()),
    path("logout/", LogoutView.as_view()),
    path("me/", MeView.as_view()),

    path("register/send-otp/", SendOTPView.as_view()),
    path("register/verify-otp/", VerifyOTPView.as_view()),
]
