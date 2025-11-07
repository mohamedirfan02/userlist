import 'package:flutter/material.dart';
import 'package:userlist/models/address_model.dart';

/// A screen that displays the details of a single address.
class AddressDetailScreen extends StatelessWidget {
  /// The address to display.
  final Address address;

  /// Creates an instance of [AddressDetailScreen].
  const AddressDetailScreen({Key? key, required this.address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Address Details'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Address Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Divider(height: 25, thickness: 1.2),
                // Builds a row for each piece of address information.
                _buildInfoRow('Name', address.name),
                _buildInfoRow('Street', address.street),
                _buildInfoRow('City', address.city),
                _buildInfoRow('Zip Code', address.zipCode),
                _buildInfoRow('Phone', address.phone),
                const SizedBox(height: 30),
                Center(
                  child:ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Address', style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      // Navigates to the edit address screen.
                      final updatedAddress = await Navigator.pushNamed(
                        context,
                        '/edit-address',
                        arguments: address,
                      ) as Address?;

                      // If the address was updated, refresh the screen with the new data.
                      if (updatedAddress != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddressDetailScreen(address: updatedAddress),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )

                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// A helper widget to build a row of information with a label and a value.
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
