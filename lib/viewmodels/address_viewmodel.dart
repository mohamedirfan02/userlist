
import 'package:flutter/material.dart';
import '../data/repositories/address_repository.dart';
import '../models/address_model.dart';

/// [AddressViewModel] manages the state for the address-related features.
///
/// It interacts with the [AddressRepository] to perform CRUD operations on addresses
/// and notifies listeners of any state changes.
class AddressViewModel with ChangeNotifier {
  final AddressRepository _addressRepository = AddressRepository();

  // State properties
  List<Address> _addresses = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters to expose state properties to the UI
  /// The list of addresses.
  List<Address> get addresses => _addresses;
  /// Whether the view model is currently processing a request.
  bool get isLoading => _isLoading;
  /// The last error message, if any.
  String? get errorMessage => _errorMessage;

  /// Fetches the list of addresses from the repository.
  Future<void> fetchAddresses() async {
    _setLoading(true);
    try {
      _addresses = await _addressRepository.fetchAddresses();
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  /// Adds a new address.
  ///
  /// Returns `true` if the address was added successfully, `false` otherwise.
  Future<bool> addAddress(Address address) async {
    _setLoading(true);
    try {
      final newAddress = await _addressRepository.addAddress(address);
      _addresses.insert(0, newAddress);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// Updates an existing address.
  ///
  /// Returns `true` if the address was updated successfully, `false` otherwise.
  Future<bool> updateAddress(Address address) async {
    _setLoading(true);
    try {
      await _addressRepository.updateAddress(address);
      int index = _addresses.indexWhere((a) => a.id == address.id);
      if (index != -1) {
        _addresses[index] = address;
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// Deletes an address.
  ///
  /// Returns `true` if the address was deleted successfully, `false` otherwise.
  Future<bool> deleteAddress(String id) async {
    _setLoading(true);
    try {
      await _addressRepository.deleteAddress(id);
      _addresses.removeWhere((address) => address.id == id);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// A private helper method to manage the loading state and notify listeners.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
