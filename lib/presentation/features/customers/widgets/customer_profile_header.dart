import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/customers/customer_profile_header_card.dart';
import '../../../../domain/entities/customer.dart';

/// Feature adapter — maps [Customer] to shared [CustomerProfileHeaderCard].
class CustomerProfileHeader extends StatelessWidget {
  const CustomerProfileHeader({super.key, required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    return CustomerProfileHeaderCard(
      customer: CustomerProfileData(
        displayName: customer.displayName,
        typeLabel: customer.type.arabicLabel,
        isCompany: customer.type == CustomerType.company,
      ),
    );
  }
}
