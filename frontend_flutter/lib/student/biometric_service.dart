import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final LocalAuthentication _auth =
      LocalAuthentication();

  static Future<bool> authenticate() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();

      // Emulator fallback (VERY IMPORTANT)
      if (!canCheck || !isSupported) {
        return true; // allow for demo
      }

      return await _auth.authenticate(
        localizedReason:
            'Authenticate to mark attendance',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}
