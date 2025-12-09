
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:userlist/comman/widgets/address_list_shimmer.dart';
import 'package:userlist/models/address_model.dart';
import 'package:userlist/viewmodels/address_viewmodel.dart';
import 'package:userlist/viewmodels/auth_viewmodel.dart';

/// A screen that displays a list of addresses.
class AddressListScreen extends StatefulWidget {
  const AddressListScreen({Key? key}) : super(key: key);

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetches the addresses when the screen is initialized.
    Future.microtask(() =>
        Provider.of<AddressViewModel>(context, listen: false).fetchAddresses());
  }

  /// A callback to handle the back button press.
  ///
  /// It shows a confirmation dialog before exiting the app.
  Future<bool> _onWillPop() async {
    bool? exitConfirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No',style: TextStyle(color: Colors.black),),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Yes',style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (exitConfirmed == true) {
      exit(0); // Close the app
    }

    return false; // Prevent default pop
  }

  /// Shows a confirmation dialog before deleting an address.
  void _deleteAddress(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Address'),
          content: const Text('Are you sure you want to delete this address?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                bool success = await Provider.of<AddressViewModel>(
                  context,
                  listen: false,
                ).deleteAddress(id);

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Address deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final addressViewModel = Provider.of<AddressViewModel>(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.blue,
          centerTitle: true,
          title: const Text(
            'My Addresses',
            style: TextStyle(
              color: Colors.white60,
              fontWeight: FontWeight.bold,
            ),
          ),
          leadingWidth: 60,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: GestureDetector(
              onTap: () {},
              child: const CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(
                  'https://cdn-icons-png.flaticon.com/512/149/149071.png',
                ),
              ),
            ),
          ),
          actions: [
            // Logout button
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              onPressed: () {
                Provider.of<AuthViewModel>(context, listen: false).signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => addressViewModel.fetchAddresses(),
            child: addressViewModel.isLoading && addressViewModel.addresses.isEmpty
                ? const AddressListShimmer() // 👈 shimmer added here
                : addressViewModel.addresses.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: addressViewModel.addresses.length,
              itemBuilder: (context, index) {
                Address address = addressViewModel.addresses[index];
                return _buildAddressCard(context, address);
              },
            ),
          ),
        ),

        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, '/add-address'),
          icon: const Icon(Icons.add),
          label: const Text('Add Address'),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }

  /// A helper widget to build a card for a single address.
  Widget _buildAddressCard(BuildContext context, Address address) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // The [Slidable] widget provides the swipe-to-reveal actions.
      child: Slidable(
        key: ValueKey(address.id),
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                Navigator.pushNamed(
                  context,
                  '/edit-address',
                  arguments: address,
                );
              },
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                _deleteAddress(context, address.id!);
              },
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/address-detail',
              arguments: address,
            );

          },
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.blue,
              size: 28,
            ),
          ),
          title: Text(
            address.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Colors.black87,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
              '${address.street}, ${address.city} - ${address.zipCode}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
        ),

      ),
    );
  }

  /// A helper widget to build the empty state UI.
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/empty_location.png', height: 150),
            const SizedBox(height: 20),
            const Text(
              'No addresses found',
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            const Text(
              'Start adding your delivery addresses to make things easier!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/add-address');
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Address',style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
