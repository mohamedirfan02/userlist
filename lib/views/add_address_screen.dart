
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:userlist/models/address_model.dart';
import 'package:userlist/viewmodels/address_viewmodel.dart';

/// A screen that allows users to add a new address.
class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({Key? key}) : super(key: key);

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _phoneController = TextEditingController();

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
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    if (!RegExp(r'^[0-9+\-() ]+$').hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// A helper method to validate a zip code.
  String? _validateZipCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Zip code is required';
    }
    if (value.length < 5) {
      return 'Zip code must be at least 5 characters';
    }
    return null;
  }

  /// Submits the form to add a new address.
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      Address newAddress = Address(
        name: _nameController.text.trim(),
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        zipCode: _zipCodeController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      bool success = await Provider.of<AddressViewModel>(
        context,
        listen: false,
      ).addAddress(newAddress);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Address added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Failed to add address'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeBlue = Colors.blueAccent;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            backgroundColor: themeBlue,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                "Add New Address",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // FORM BODY
          SliverToBoxAdapter(
            child: Consumer<AddressViewModel>(
              builder: (context, addressViewModel, child) {
                return Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildInputCard(
                          controller: _nameController,
                          label: "Full Name",
                          icon: Icons.person_outline,
                          validator: (v) => _validateRequired(v, "Name"),
                        ),
                        const SizedBox(height: 18),
                        _buildInputCard(
                          controller: _streetController,
                          label: "Street Address",
                          icon: Icons.home_outlined,
                          validator: (v) =>
                              _validateRequired(v, "Street Address"),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 18),
                        _buildInputCard(
                          controller: _cityController,
                          label: "City",
                          icon: Icons.location_city,
                          validator: (v) => _validateRequired(v, "City"),
                        ),
                        const SizedBox(height: 18),
                        _buildInputCard(
                          controller: _zipCodeController,
                          label: "Zip Code",
                          icon: Icons.pin_drop_outlined,
                          validator: _validateZipCode,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 18),
                        _buildInputCard(
                          controller: _phoneController,
                          label: "Phone Number",
                          icon: Icons.phone_outlined,
                          validator: _validatePhone,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 40),

                        // SUBMIT BUTTON
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: addressViewModel.isLoading
                                  ? [Colors.grey, Colors.grey]
                                  : [Colors.blueAccent, Colors.indigoAccent],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: addressViewModel.isLoading
                                ? null
                                : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: addressViewModel.isLoading
                                ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                                : const Text(
                              "Save Address",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
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
        ],
      ),
    );
  }

  /// A helper widget to build a styled input card.
  Widget _buildInputCard({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.blue[50]?.withOpacity(0.4),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 15.5),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          floatingLabelStyle: const TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
