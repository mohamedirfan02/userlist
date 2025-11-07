
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sim_card_info/sim_card_info.dart';
import 'package:sim_card_info/sim_info.dart';

/// [AuthRepository] is responsible for handling all authentication-related data operations.
/// It abstracts the data source (in this case, device hardware and a mock OTP) from the rest of the app.
class AuthRepository {
  /// A static OTP used for testing purposes.
  /// In a real application, this would be generated and sent by a server.
  static const String STATIC_OTP = '123456';

  /// Fetches SIM card information from the device.
  ///
  /// This method only works on Android. It requests phone permissions before attempting
  /// to read SIM information.
  ///
  /// Returns a list of [SimInfo] objects if successful, otherwise returns null.
  Future<List<SimInfo>?> fetchSimCardInfo() async {
    if (!Platform.isAndroid) {
      debugPrint('⚠️ SIM reading works only on Android');
      return null;
    }

    var status = await Permission.phone.request();

    if (status.isGranted) {
      final simCardInfoPlugin = SimCardInfo();
      return await simCardInfoPlugin.getSimInfo();
    } else {
      debugPrint('⚠️ Phone permission denied');
      return null;
    }
  }

  /// Verifies the OTP entered by the user.
  ///
  /// In a real application, this method would make a request to a server to verify the OTP.
  /// For this example, it simply compares the input with a static OTP.
  ///
  /// Returns `true` if the OTP is valid, `false` otherwise.
  Future<bool> verifyOtp(String otp) async {
    // Simulate a network delay.
    await Future.delayed(const Duration(seconds: 1));
    return otp == STATIC_OTP;
  }
}
