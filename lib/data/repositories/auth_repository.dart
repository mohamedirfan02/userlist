import 'dart:io';
import 'package:sim_card_info/sim_card_info.dart';
import 'package:sim_card_info/sim_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class AuthRepository {
  // Static OTP for local testing
  static const String STATIC_OTP = '123456';

  /// Sim info read (Android only). Returns list of SimInfo or null.
  Future<List<SimInfo>?> fetchSimCardInfo() async {
    try {
      if (!Platform.isAndroid) {
        debugPrint('⚠️ SIM reading works only on Android');
        return null;
      }

      var status = await Permission.phone.request();
      if (status.isGranted) {
        final plugin = SimCardInfo();
        return await plugin.getSimInfo();
      } else {
        debugPrint('⚠️ Phone permission denied');
        return null;
      }
    } catch (e) {
      debugPrint('❌ fetchSimCardInfo error: $e');
      return null;
    }
  }

  /// Verify OTP (simulated). Replace with real API/Firebase later.
  Future<bool> verifyOtp(String otp) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return otp == STATIC_OTP;
  }
}
