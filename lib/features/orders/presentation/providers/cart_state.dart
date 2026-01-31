import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item_entity.dart';

enum CartStatus {
  initial,
  loading,
  loaded,
  error,
}

class CartState extends Equatable {
  final CartStatus status;
  final List<CartItemEntity> items;
  final String? errorMessage;
  final int? selectedPharmacyId;

  const CartState({
    required this.status,
    required this.items,
    this.errorMessage,
    this.selectedPharmacyId,
  });

  const CartState.initial()
      : status = CartStatus.initial,
        items = const [],
        errorMessage = null,
        selectedPharmacyId = null;

  CartState copyWith({
    CartStatus? status,
    List<CartItemEntity>? items,
    String? errorMessage,
    int? selectedPharmacyId,
    bool clearPharmacyId = false,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
      selectedPharmacyId: clearPharmacyId ? null : (selectedPharmacyId ?? this.selectedPharmacyId),
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage, selectedPharmacyId];

  // Helper getters
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get itemCount => items.length;
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  // Delivery fee calculation (simplified - 500 XOF flat rate)
  double get deliveryFee => isNotEmpty ? 500.0 : 0.0;
  
  double get total => subtotal + deliveryFee;

  // Check if cart has items from a specific pharmacy
  bool hasPharmacyItems(int pharmacyId) {
    return items.any((item) => item.product.pharmacy.id == pharmacyId);
  }

  // Get item by product ID
  CartItemEntity? getItem(int productId) {
    try {
      return items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }
}
