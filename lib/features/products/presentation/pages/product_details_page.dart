import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/cached_image.dart';
import '../providers/products_provider.dart';
import '../providers/products_state.dart';
import '../../../orders/presentation/providers/cart_provider.dart';
import '../../../orders/presentation/providers/cart_state.dart';

class ProductDetailsPage extends ConsumerStatefulWidget {
  final int productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends ConsumerState<ProductDetailsPage> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'fr_CI',
    symbol: 'F CFA',
    decimalDigits: 0,
  );

  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Load product details when page opens
    Future.microtask(() {
      ref.read(productsProvider.notifier).loadProductDetails(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    final cartState = ref.watch(cartProvider);
    final product = productsState.selectedProduct;

    // Show cart error as snackbar
    if (cartState.status == CartStatus.error &&
        cartState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cartState.errorMessage!),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ref.read(cartProvider.notifier).clearError();
              },
            ),
          ),
        );
        ref.read(cartProvider.notifier).clearError();
      });
    }

    return Scaffold(
      body: productsState.status == ProductsStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : productsState.status == ProductsStatus.error
          ? _buildError(productsState.errorMessage)
          : product == null
          ? _buildError('Produit non trouvé')
          : _buildProductDetails(product),
      floatingActionButton: product != null && product.isAvailable
          ? _buildAddToCartFAB(product)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAddToCartFAB(dynamic product) {
    final cartItem = ref.watch(cartProvider).getItem(product.id);
    final currentQuantity = cartItem?.quantity ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: Row(
        children: [
          // Quantity selector
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: _quantity > 1
                      ? () => setState(() => _quantity--)
                      : null,
                  icon: const Icon(Icons.remove),
                  color: AppColors.primary,
                ),
                Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _quantity < product.stockQuantity
                      ? () => setState(() => _quantity++)
                      : null,
                  icon: const Icon(Icons.add),
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Add to cart button
          Expanded(
            child: FloatingActionButton.extended(
              onPressed: () {
                ref
                    .read(cartProvider.notifier)
                    .addItem(product, quantity: _quantity);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      currentQuantity > 0
                          ? 'Quantité mise à jour: ${currentQuantity + _quantity}'
                          : 'Ajouté au panier',
                    ),
                    backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.shopping_cart),
              label: Text(
                currentQuantity > 0
                    ? 'Mettre à jour ($currentQuantity)'
                    : 'Ajouter au panier',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            message ?? 'Une erreur s\'est produite',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Retour'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails(dynamic product) {
    return CustomScrollView(
      slivers: [
        // App Bar with Image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: AppColors.primary,
          flexibleSpace: FlexibleSpaceBar(
            background: product.imageUrl != null
                ? Hero(
                    tag: 'product-image-${product.id}',
                    child: ProductImage(
                      imageUrl: product.imageUrl!,
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: BorderRadius.zero,
                    ),
                  )
                : Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.medication, size: 100),
                  ),
          ),
        ),

        // Product Details
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Manufacturer
                if (product.manufacturer != null)
                  Text(
                    product.manufacturer!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: 16),

                // Price
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Prix:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _currencyFormat.format(product.price),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Stock Status
                _buildInfoRow(
                  'Stock',
                  product.isAvailable
                      ? '${product.stockQuantity} disponible(s)'
                      : 'Rupture de stock',
                  product.isAvailable ? AppColors.success : AppColors.error,
                ),
                const SizedBox(height: 8),

                // Prescription Required
                _buildInfoRow(
                  'Ordonnance',
                  product.requiresPrescription ? 'Requise' : 'Non requise',
                  product.requiresPrescription
                      ? AppColors.warning
                      : AppColors.success,
                ),
                const SizedBox(height: 16),

                // Description
                if (product.description != null) ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description!,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],

                // Pharmacy Info
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Pharmacie',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildPharmacyCard(product.pharmacy),
                const SizedBox(height: 100), // Space for FAB
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPharmacyCard(dynamic pharmacy) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_pharmacy, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    pharmacy.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pharmacy.address,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.phone,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  pharmacy.phone,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
