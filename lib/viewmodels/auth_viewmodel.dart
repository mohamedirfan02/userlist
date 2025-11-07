
import 'package:flutter/material.dart';
import 'package:userlist/data/repositories/auth_repository.dart';
import 'package:sim_card_info/sim_info.dart';

/// [AuthViewModel] manages the state for the authentication process.
///
/// It interacts with the [AuthRepository] to perform authentication tasks
/// and notifies listeners of any state changes.
class AuthViewModel with ChangeNotifier {
  final AuthRepository _authRepository;

  /// Creates an instance of [AuthViewModel].
  ///
  /// Requires an [AuthRepository] to handle the authentication logic.
  AuthViewModel(this._authRepository);

  // State properties
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;
  String? _phoneNumber;
  List<SimInfo>? _availableSimCards;

  // Getters to expose state properties to the UI
  /// Whether the view model is currently processing a request.
  bool get isLoading => _isLoading;
  /// The last error message, if any.
  String? get errorMessage => _errorMessage;
  /// Whether the user is currently authenticated.
  bool get isAuthenticated => _isAuthenticated;
  /// The user's phone number.
  String? get phoneNumber => _phoneNumber;
  /// A list of available SIM cards on the device.
  List<SimInfo>? get availableSimCards => _availableSimCards;

  /// Fetches SIM card information from the device.
  ///
  /// If only one SIM card is found, it automatically sets the phone number.
  Future<void> fetchSimPhoneNumber() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _availableSimCards = await _authRepository.fetchSimCardInfo();
      if (_availableSimCards != null && _availableSimCards!.length == 1) {
        _setPhoneNumberFromSim(_availableSimCards!.first);
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch SIM information.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// A private helper method to format and set the phone number from a [SimInfo] object.
  ///
  /// It removes the country code if present.
  void _setPhoneNumberFromSim(SimInfo simInfo) {
    String? rawNumber = simInfo.number;

    if (rawNumber != null && rawNumber.isNotEmpty) {
      if (rawNumber.startsWith('+91')) {
        _phoneNumber = rawNumber.substring(3);
      } else if (rawNumber.startsWith('+')) {
        // Handles other country codes by removing them
        _phoneNumber = rawNumber.replaceFirst(RegExp(r'^\+\d{1,3}'), '');
      } else {
        _phoneNumber = rawNumber;
      }
    }
    notifyListeners();
  }

  /// Sets the phone number based on the selected SIM card.
  Future<void> selectSim(SimInfo simInfo) async {
    _setPhoneNumberFromSim(simInfo);
  }

  /// Verifies the OTP entered by the user.
  ///
  /// Returns `true` if the OTP is valid, `false` otherwise.
  Future<bool> verifyOtp(String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final success = await _authRepository.verifyOtp(otp);

    if (success) {
      _isAuthenticated = true;
    } else {
      _errorMessage = 'Invalid OTP. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  /// Signs the user out and resets the authentication state.
  Future<void> signOut() async {
    _isAuthenticated = false;
    _phoneNumber = null;
    _availableSimCards = null;
    notifyListeners();
  }
}
