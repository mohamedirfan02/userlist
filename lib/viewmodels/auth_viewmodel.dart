import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sim_card_info/sim_info.dart';
import '../data/repositories/auth_repository.dart';
import '../core/constant/app_hive_storage_constants.dart';

class AuthViewModel with ChangeNotifier {
  final AuthRepository _repo;

  AuthViewModel(this._repo);

  // State
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;
  String? _phoneNumber;
  List<SimInfo>? _availableSimCards;

  // Hive box (opened in main)
  final Box _authBox = Hive.box(AppHiveStorageConstants.authBoxKey);

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  String? get phoneNumber => _phoneNumber;
  List<SimInfo>? get availableSimCards => _availableSimCards;

  /// Initialize from Hive - call once on app startup
  Future<void> initAuthState() async {
    _isAuthenticated = _authBox.get(
      AppHiveStorageConstants.isAuthLoggedInStatus,
      defaultValue: false,
    );
    _phoneNumber = _authBox.get(AppHiveStorageConstants.userPhoneNumber);
    notifyListeners();
  }

  /// Set phone number (from input or SIM) — does NOT persist until login
  void setPhoneNumber(String phone) {
    _phoneNumber = phone;
    notifyListeners();
  }

  /// Fetch SIM card info and auto fill phone when appropriate
  Future<void> fetchSimPhoneNumber() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _availableSimCards = await _repo.fetchSimCardInfo();
      if (_availableSimCards != null && _availableSimCards!.length == 1) {
        final sim = _availableSimCards!.first;
        _setPhoneFromSim(sim);
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch SIM information';
    }

    _setLoading(false);
  }

  void _setPhoneFromSim(SimInfo simInfo) {
    final raw = simInfo.number;
    if (raw != null && raw.isNotEmpty) {
      if (raw.startsWith('+91')) {
        _phoneNumber = raw.substring(3);
      } else if (raw.startsWith('+')) {
        _phoneNumber = raw.replaceFirst(RegExp(r'^\+\d{1,3}'), '');
      } else {
        _phoneNumber = raw;
      }
      notifyListeners();
    }
  }

  /// Verify OTP, persist login state + phone on success
  Future<bool> verifyOtp(String otp) async {
    _setLoading(true);
    _errorMessage = null;

    final success = await _repo.verifyOtp(otp);

    if (success) {
      _isAuthenticated = true;

      // Persist to Hive
      await _authBox.put(AppHiveStorageConstants.isAuthLoggedInStatus, true);
      if (_phoneNumber != null) {
        await _authBox.put(AppHiveStorageConstants.userPhoneNumber, _phoneNumber);
      }
      debugPrint('✅ Saved Hive login: ${_authBox.get(AppHiveStorageConstants.isAuthLoggedInStatus)}');
      debugPrint('✅ Saved Hive phone: ${_authBox.get(AppHiveStorageConstants.userPhoneNumber)}');
    } else {
      _errorMessage = 'Invalid OTP';
      _isAuthenticated = false;
    }

    _setLoading(false);
    return success;
  }

  /// Sign out — clear persisted state
  Future<void> signOut() async {
    _isAuthenticated = false;
    _phoneNumber = null;
    _availableSimCards = null;
    await _authBox.put(AppHiveStorageConstants.isAuthLoggedInStatus, false);
    await _authBox.delete(AppHiveStorageConstants.userPhoneNumber);
    notifyListeners();
  }

  // helpers
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
