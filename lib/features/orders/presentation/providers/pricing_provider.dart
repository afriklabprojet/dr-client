import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/providers.dart';
import '../../data/datasources/pricing_datasource.dart';

/// Provider pour le DataSource de tarification
final pricingDataSourceProvider = Provider<PricingDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PricingDataSource(apiClient: apiClient);
});

/// État de la configuration de tarification
class PricingState {
  final bool isLoading;
  final PricingConfig? config;
  final String? error;

  const PricingState({
    this.isLoading = false,
    this.config,
    this.error,
  });

  const PricingState.initial()
      : isLoading = false,
        config = null,
        error = null;

  PricingState copyWith({
    bool? isLoading,
    PricingConfig? config,
    String? error,
  }) {
    return PricingState(
      isLoading: isLoading ?? this.isLoading,
      config: config ?? this.config,
      error: error,
    );
  }
}

/// Notifier pour gérer la configuration de tarification
class PricingNotifier extends StateNotifier<PricingState> {
  final PricingDataSource _dataSource;

  PricingNotifier(this._dataSource) : super(const PricingState.initial());

  /// Charger la configuration de tarification depuis l'API
  Future<void> loadPricing() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final config = await _dataSource.getPricing();
      state = state.copyWith(isLoading: false, config: config);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement de la tarification: $e',
      );
    }
  }

  /// Calculer les frais pour un panier
  /// Utilise le calcul local si la config est disponible, sinon appelle l'API
  PricingCalculation? calculateFees({
    required int subtotal,
    required int deliveryFee,
    required String paymentMode,
  }) {
    if (state.config == null) return null;

    return PricingCalculation.calculate(
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      paymentMode: paymentMode,
      config: state.config!,
    );
  }

  /// Calculer les frais de livraison pour une distance
  int? calculateDeliveryFee(double distanceKm) {
    if (state.config == null) return null;
    return state.config!.delivery.calculateFee(distanceKm);
  }
}

/// Provider principal pour la tarification
final pricingProvider = StateNotifierProvider<PricingNotifier, PricingState>((ref) {
  final dataSource = ref.watch(pricingDataSourceProvider);
  return PricingNotifier(dataSource);
});

/// Provider pour obtenir la config de tarification (auto-load)
final pricingConfigProvider = FutureProvider<PricingConfig?>((ref) async {
  final notifier = ref.watch(pricingProvider.notifier);
  final state = ref.watch(pricingProvider);
  
  if (state.config == null && !state.isLoading) {
    await notifier.loadPricing();
  }
  
  return ref.watch(pricingProvider).config;
});
