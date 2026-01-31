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

  const OrderSummaryCard({
    super.key,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.currencyFormat,
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
            _buildSummaryRow('Frais de livraison', deliveryFee),
            const SizedBox(height: 8),
            _buildTotalRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(CartItemEntity item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${item.product.name} x${item.quantity}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            currencyFormat.format(item.totalPrice),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(label)),
        Flexible(
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(
          child: Text(
            'Total',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Flexible(
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
