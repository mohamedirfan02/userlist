/// Represents a single address.
class Address {
  /// The unique identifier of the address.
  final String? id;
  /// The name of the person associated with the address.
  final String name;
  /// The street address.
  final String street;
  /// The city.
  final String city;
  /// The ZIP code.
  final String zipCode;
  /// The phone number associated with the address.
  final String phone;

  /// Creates an instance of [Address].
  Address({
    this.id,
    required this.name,
    required this.street,
    required this.city,
    required this.zipCode,
    required this.phone,
  });

  /// Creates an [Address] from a JSON object.
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      street: json['street_address'] ?? '',
      city: json['city'] ?? '',
      zipCode: json['pin_code']?.toString() ?? '',
      phone: json['phone_number']?.toString() ?? '',
    );
  }

  /// Converts this [Address] object to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "street_address": street,
      "city": city,
      "pin_code": int.tryParse(zipCode) ?? 0,
      "phone_number": int.tryParse(phone) ?? 0,
    };
  }

  /// Creates a copy of this [Address] but with the given fields replaced with the new values.
  Address copyWith({
    String? id,
    String? name,
    String? street,
    String? city,
    String? zipCode,
    String? phone,
  }) {
    return Address(
      id: id ?? this.id,
      name: name ?? this.name,
      street: street ?? this.street,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      phone: phone ?? this.phone,
    );
  }
}
