
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/address_model.dart';

/// [AddressRepository] is responsible for handling all the data operations
/// related to addresses. It abstracts the data source from the rest of the app.
class AddressRepository {
  /// The base URL for the address API.
  static const String BASE_URL =
      'https://690c70dfa6d92d83e84dc0a3.mockapi.io/api/users/users';

  /// Fetches a list of addresses from the API.
  ///
  /// Returns a list of [Address] objects.
  /// Throws an exception if the request fails.
  Future<List<Address>> fetchAddresses() async {
    final response = await http.get(Uri.parse(BASE_URL));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Address.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load addresses (Code: ${response.statusCode})');
    }
  }

  /// Adds a new address to the API.
  ///
  /// Takes an [Address] object as input and returns the newly created address.
  /// Throws an exception if the request fails.
  Future<Address> addAddress(Address address) async {
    final response = await http.post(
      Uri.parse(BASE_URL),
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

  /// Updates an existing address in the API.
  ///
  /// Takes an [Address] object as input.
  /// Throws an exception if the request fails.
  Future<void> updateAddress(Address address) async {
    final response = await http.put(
      Uri.parse('$BASE_URL/${address.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(address.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update address');
    }
  }

  /// Deletes an address from the API.
  ///
  /// Takes the ID of the address to delete.
  /// Throws an exception if the request fails.
  Future<void> deleteAddress(String id) async {
    final response = await http.delete(Uri.parse('$BASE_URL/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete address (code: ${response.statusCode})');
    }
  }
}
