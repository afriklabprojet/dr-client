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
  
  /// Frais de livraison calculés dynamiquement selon la distance
  /// null = pas encore calculé (utiliser le minimum par défaut)
  final double? calculatedDeliveryFee;
  
  /// Distance en km pour la livraison (pour affichage)
  final double? deliveryDistanceKm;

  const CartState({
    required this.status,
    required this.items,
    this.errorMessage,
    this.selectedPharmacyId,
    this.calculatedDeliveryFee,
    this.deliveryDistanceKm,
  });

  const CartState.initial()
      : status = CartStatus.initial,
        items = const [],
        errorMessage = null,
        selectedPharmacyId = null,
        calculatedDeliveryFee = null,
        deliveryDistanceKm = null;

  CartState copyWith({
    CartStatus? status,
    List<CartItemEntity>? items,
    String? errorMessage,
    int? selectedPharmacyId,
    bool clearPharmacyId = false,
    double? calculatedDeliveryFee,
    double? deliveryDistanceKm,
    bool clearDeliveryFee = false,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
      selectedPharmacyId: clearPharmacyId ? null : (selectedPharmacyId ?? this.selectedPharmacyId),
      calculatedDeliveryFee: clearDeliveryFee ? null : (calculatedDeliveryFee ?? this.calculatedDeliveryFee),
      deliveryDistanceKm: clearDeliveryFee ? null : (deliveryDistanceKm ?? this.deliveryDistanceKm),
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage, selectedPharmacyId, calculatedDeliveryFee, deliveryDistanceKm];

  // Helper getters
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  
  /// Nombre total d'articles (somme des quantités) - utilisé pour le badge
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  
  /// Nombre de produits différents dans le panier
  int get uniqueProductCount => items.length;
  
  /// Alias pour itemCount (rétrocompatibilité)
  int get totalQuantity => itemCount;
  
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  /// Frais de livraison minimum par défaut (utilisé avant calcul)
  static const double defaultMinDeliveryFee = 300.0;
  
  /// Frais de livraison:
  /// - Si calculés dynamiquement: utilise calculatedDeliveryFee
  /// - Sinon: utilise le minimum par défaut (300 FCFA)
  /// - Si panier vide: 0
  double get deliveryFee {
    if (isEmpty) return 0.0;
    return calculatedDeliveryFee ?? defaultMinDeliveryFee;
  }
  
  /// Indique si les frais ont été calculés dynamiquement
  bool get hasCalculatedDeliveryFee => calculatedDeliveryFee != null;
  
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

  /// Vérifie si le panier contient des produits nécessitant une ordonnance
  bool get hasPrescriptionRequiredItems {
    return items.any((item) => item.product.requiresPrescription);
  }

  /// Retourne la liste des produits nécessitant une ordonnance
  List<CartItemEntity> get prescriptionRequiredItems {
    return items.where((item) => item.product.requiresPrescription).toList();
  }

  /// Retourne les noms des produits nécessitant une ordonnance
  List<String> get prescriptionRequiredProductNames {
    return prescriptionRequiredItems.map((item) => item.product.name).toList();
  }
}
