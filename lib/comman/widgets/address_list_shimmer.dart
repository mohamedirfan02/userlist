import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AddressListShimmer extends StatelessWidget {
  const AddressListShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              title: Container(
                height: 14,
                width: 120,
                color: Colors.grey[300],
              ),
              subtitle: Container(
                margin: const EdgeInsets.only(top: 8),
                height: 12,
                width: 200,
                color: Colors.grey[300],
              ),
            ),
          ),
        );
      },
    );
  }
}
