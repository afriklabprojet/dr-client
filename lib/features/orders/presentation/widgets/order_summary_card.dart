import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/cart_item_entity.dart';

/// Widget affichant le résumé de la commande
class OrderSummaryCard extends StatelessWidget {
  final List<CartItemEntity> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final NumberFormat currencyFormat;
  final double? distanceKm;
  final bool isLoadingDeliveryFee;

  const OrderSummaryCard({
    super.key,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.currencyFormat,
    this.distanceKm,
    this.isLoadingDeliveryFee = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Résumé de la commande',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            ...items.map((item) => _buildItemRow(item)),
            const Divider(height: 24),
            _buildSummaryRow('Sous-total', subtotal),
            const SizedBox(height: 8),
            _buildDeliveryFeeRow(),
            const SizedBox(height: 8),
            _buildTotalRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryFeeRow() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Frais de livraison'),
              if (distanceKm != null)
                Text(
                  '${distanceKm!.toStringAsFixed(1)} km',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: isLoadingDeliveryFee
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                )
              : Text(
                  currencyFormat.format(deliveryFee),
                  textAlign: TextAlign.end,
                ),
        ),
      ],
    );
  }

  Widget _buildItemRow(CartItemEntity item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '${item.product.name} x${item.quantity}',
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              currencyFormat.format(item.totalPrice),
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            currencyFormat.format(amount),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow() {
    return Row(
      children: [
        const Expanded(
          flex: 2,
          child: Text(
            'Total',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            currencyFormat.format(total),
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
