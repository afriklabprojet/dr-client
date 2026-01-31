import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

/// Widget pour sélectionner le mode de paiement
class PaymentModeSelector extends StatelessWidget {
  final String selectedMode;
  final ValueChanged<String> onModeChanged;

  const PaymentModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPaymentOption(
          value: AppConstants.paymentModePlatform,
          title: 'Paiement en ligne',
          subtitle: 'Payez maintenant par mobile money',
          icon: Icons.payment,
        ),
        _buildPaymentOption(
          value: AppConstants.paymentModeOnDelivery,
          title: 'Paiement à la livraison',
          subtitle: 'Payez en espèces lors de la réception',
          icon: Icons.local_shipping,
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return RadioListTile<String>(
      value: value,
      groupValue: selectedMode,
      onChanged: (newValue) {
        if (newValue != null) {
          onModeChanged(newValue);
        }
      },
      title: Text(title),
      subtitle: Text(subtitle),
      secondary: Icon(icon, color: AppColors.primary),
    );
  }
}
