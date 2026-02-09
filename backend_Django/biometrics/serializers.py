from rest_framework import serializers


class BiometricRegisterSerializer(serializers.Serializer):
    biometric_type = serializers.ChoiceField(
        choices=["FACE", "IRIS"]
    )
    biometric_template = serializers.CharField()
