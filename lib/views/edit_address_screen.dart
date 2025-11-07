
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:userlist/models/address_model.dart';
import 'package:userlist/viewmodels/address_viewmodel.dart';

/// A screen that allows users to edit an existing address.
class EditAddressScreen extends StatefulWidget {
  const EditAddressScreen({Key? key}) : super(key: key);

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _phoneController = TextEditingController();

  Address? _address;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetches the address from the route arguments and initializes the form fields.
    if (_address == null) {
      _address = ModalRoute.of(context)!.settings.arguments as Address;
      _nameController.text = _address!.name;
      _streetController.text = _address!.street;
      _cityController.text = _address!.city;
      _zipCodeController.text = _address!.zipCode;
      _phoneController.text = _address!.phone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// A helper method to validate that a form field is not empty.
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// A helper method to validate a phone number.
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (value.length < 10) return 'Phone number must be at least 10 digits';
    if (!RegExp(r'^[0-9+\-() ]+$').hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// A helper method to validate a zip code.
  String? _validateZipCode(String? value) {
    if (value == null || value.isEmpty) return 'Zip code is required';
    if (value.length < 5) return 'Zip code must be at least 5 characters';
    return null;
  }

  /// Submits the form to update the address.
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final updatedAddress = Address(
        id: _address!.id,
        name: _nameController.text.trim(),
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        zipCode: _zipCodeController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      final viewModel = Provider.of<AddressViewModel>(context, listen: false);
      bool success = await viewModel.updateAddress(updatedAddress);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Address updated successfully'
                : 'Failed to update address',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success && mounted) {
        Navigator.pop(context, updatedAddress); // Return the updated address
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            snap: false,
            centerTitle: true,
            elevation: 0,
            expandedHeight: 130,
            backgroundColor: Colors.blue.shade600,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Edit Address',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // Main form
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Consumer<AddressViewModel>(
                builder: (context, viewModel, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.person,
                            validator: (v) => _validateRequired(v, 'Name'),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _streetController,
                            label: 'Street Address',
                            icon: Icons.home,
                            validator: (v) =>
                                _validateRequired(v, 'Street Address'),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _cityController,
                            label: 'City',
                            icon: Icons.location_city,
                            validator: (v) => _validateRequired(v, 'City'),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _zipCodeController,
                            label: 'Zip Code',
                            icon: Icons.pin_drop,
                            validator: _validateZipCode,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone,
                            validator: _validatePhone,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 30),

                          // Update Button
                          ElevatedButton(
                            onPressed: viewModel.isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: viewModel.isLoading
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text(
                              'Update Address',
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Input Field Builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade600),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
        ),
      ),
    );
  }
}
