import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:userlist/core/constant/app_api_constants.dart';
import 'package:userlist/models/address_model.dart';

/// Handles API requests for addresses.
/// Now uses centralized API constants from [AppApiConstants].
class AddressRepository {
  /// Fetch all addresses
  Future<List<Address>> fetchAddresses() async {
    final response = await http.get(Uri.parse(AppApiConstants.addressesEndpoint));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Address.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load addresses (Code: ${response.statusCode})');
    }
  }

  /// Add a new address
  Future<Address> addAddress(Address address) async {
    final response = await http.post(
      Uri.parse(AppApiConstants.addressesEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(address.toJson()),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return Address.fromJson(data);
    } else {
      throw Exception('Failed to add address');
    }
  }

  /// Update an address
  Future<void> updateAddress(Address address) async {
    final response = await http.put(
      Uri.parse('${AppApiConstants.addressesEndpoint}/${address.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(address.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update address');
    }
  }

  /// Delete an address
  Future<void> deleteAddress(String id) async {
    final response = await http.delete(
      Uri.parse('${AppApiConstants.addressesEndpoint}/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete address (Code: ${response.statusCode})');
    }
  }
}
