import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:sim_card_info/sim_card_info.dart';
import 'package:sim_card_info/sim_info.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;
  String? _phoneNumber;
  List<SimInfo>? _availableSimCards;
  String? _verificationId; // Add this in your provider

  // Static OTP for testing
  static const String STATIC_OTP = '123456';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  String? get phoneNumber => _phoneNumber;
  List<SimInfo>? get availableSimCards => _availableSimCards;

  /// Fetch phone number automatically (SIM 1 or SIM 2)
  Future<void> fetchSimPhoneNumber(BuildContext context) async {
    if (!Platform.isAndroid) {
      debugPrint('⚠️ SIM reading works only on Android');
      return;
    }

    try {
      // Request phone permission
      var status = await Permission.phone.request();

      if (status.isGranted) {
        final simCardInfoPlugin = SimCardInfo();
        List<SimInfo>? simCards = await simCardInfoPlugin.getSimInfo();

        if (simCards != null && simCards.isNotEmpty) {
          _availableSimCards = simCards;

          // If only one SIM, auto-select it
          if (simCards.length == 1) {
            _setPhoneNumberFromSim(simCards.first);
          } else {
            // Multiple SIMs - show selection dialog
            if (context.mounted) {
              _showSimSelectionDialog(context, simCards);
            }
          }
        } else {
          debugPrint('⚠️ No SIM cards found');
        }
      } else if (status.isDenied) {
        debugPrint('⚠️ Phone permission denied');
        _errorMessage = 'Phone permission is required to auto-fetch number';
      } else if (status.isPermanentlyDenied) {
        debugPrint('⚠️ Phone permission permanently denied');
        _errorMessage = 'Please enable phone permission in settings';
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch SIM number: $e');
      _errorMessage = 'Failed to fetch phone number';
    }

    notifyListeners();
  }

  void _setPhoneNumberFromSim(SimInfo simInfo) {
    String? rawNumber = simInfo.number;

    if (rawNumber != null && rawNumber.isNotEmpty) {
      // Remove only the +91 country code prefix
      if (rawNumber.startsWith('+91')) {
        _phoneNumber = rawNumber.substring(3); // Remove '+91' (3 characters)
      } else if (rawNumber.startsWith('+')) {
        // For other country codes, remove + and country code (1-3 digits)
        _phoneNumber = rawNumber.replaceFirst(RegExp(r'^\+\d{1,3}'), '');
      } else {
        _phoneNumber = rawNumber;
      }

      debugPrint('📱 Selected SIM: ${simInfo.displayName} - Number: $_phoneNumber (from $rawNumber)');
    }

    notifyListeners();
  }

  void _showSimSelectionDialog(BuildContext context, List<SimInfo> simCards) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Select SIM Card'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: simCards.map((sim) {
              return ListTile(
                leading: CircleAvatar(
                  child: Text('${(simCards.indexOf(sim) + 1)}'),
                ),
                title: Text(sim.displayName ?? 'SIM ${simCards.indexOf(sim) + 1}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (sim.carrierName != null)
                      Text('Carrier: ${sim.carrierName}'),
                    if (sim.number != null)
                      Text('Number: ${sim.number}'),
                  ],
                ),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _setPhoneNumberFromSim(sim);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Verify phone number without Firebase (test mode)
  Future<void> verifyPhoneNumber(String phoneNumber, BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    _phoneNumber = phoneNumber;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();

    if (context.mounted) {
      _showOTPDialog(context);
    }
  }




  void _showOTPDialog(BuildContext context) {
    String enteredOTP = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final size = MediaQuery.of(dialogContext).size;
        final screenWidth = size.width;
        final dialogWidth = screenWidth * 0.9;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          titlePadding: const EdgeInsets.all(16),

          title: Row(
            children: const [
              Icon(Icons.lock_outline, color: Colors.blueAccent, size: 26),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  'OTP Verification',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          content: SingleChildScrollView(
            child: SizedBox(
              width: dialogWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'A 6-digit OTP has been sent to your phone number.',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // 🔵 OTP Hint Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blueAccent),
                    ),
                    child: const Text(
                      'Test OTP: 123456',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ✅ FIXED OTP FIELD - fully responsive using MediaQuery
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final fieldWidth =
                          (constraints.maxWidth - 50) / 6; // auto adjust per screen
                      return OtpTextField(
                        numberOfFields: 6,
                        fieldWidth: fieldWidth,
                        borderColor: Colors.blueAccent,
                        focusedBorderColor: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                        showFieldAsBox: true,
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        onCodeChanged: (String code) {},
                        onSubmit: (String verificationCode) {
                          enteredOTP = verificationCode;
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 10),
                  const Text(
                    'Please enter the 6-digit code to verify',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            // ❌ Cancel Button
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _isLoading = false;
                notifyListeners();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text('Cancel'),
            ),

            // ✅ Verify Button
            ElevatedButton.icon(
              onPressed: () async {
                if (enteredOTP == STATIC_OTP) {
                  Navigator.pop(dialogContext);
                  await _signInWithOTP(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid OTP. Please use: 123456'),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.check_circle_outline,
                  color: Colors.white, size: 18),
              label: const Text('Verify'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }




  Future<void> _signInWithOTP(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _isAuthenticated = true;
    _isLoading = false;
    notifyListeners();

    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/address-list');
    }
  }

  Future<void> signOut() async {
    _isAuthenticated = false;
    _phoneNumber = null;
    _availableSimCards = null;
    notifyListeners();
  }
}