// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/app_logger.dart';
import '../../../addresses/domain/entities/address_entity.dart';
import '../../../addresses/presentation/providers/addresses_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../domain/entities/delivery_address_entity.dart';
import '../providers/orders_state.dart';
import '../providers/orders_provider.dart';
import '../widgets/widgets.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _addressLabelController = TextEditingController();

  String _paymentMode = AppConstants.paymentModePlatform;
  bool _useManualAddress = false;
  bool _saveNewAddress = false;
  bool _isSubmitting = false;
  AddressEntity? _selectedSavedAddress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAndSelectDefaultAddress();
      _prefillUserPhone();
    });
  }

  Future<void> _loadAndSelectDefaultAddress() async {
    await ref.read(addressesProvider.notifier).loadAddresses();
    final state = ref.read(addressesProvider);
    if (state.defaultAddress != null) {
      setState(() {
        _selectedSavedAddress = state.defaultAddress;
        _useManualAddress = false;
      });
    } else if (state.addresses.isEmpty) {
      setState(() => _useManualAddress = true);
    }
  }

  void _prefillUserPhone() {
    final authState = ref.read(authProvider);
    if (authState.user != null && _phoneController.text.isEmpty) {
      _phoneController.text = authState.user!.phone;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _addressLabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final ordersState = ref.watch(ordersProvider);
    final addressesState = ref.watch(addressesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currencyFormat = NumberFormat.currency(
      locale: AppConstants.currencyLocale,
      symbol: AppConstants.currencySymbol,
      decimalDigits: 0,
    );

    if (cartState.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Validation de la commande'),
        backgroundColor: AppColors.primary,
      ),
      body: ordersState.status == OrdersStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary
                    OrderSummaryCard(
                      items: cartState.items,
                      subtotal: cartState.subtotal,
                      deliveryFee: cartState.deliveryFee,
                      total: cartState.total,
                      currencyFormat: currencyFormat,
                    ),
                    const SizedBox(height: 24),

                    // Delivery Address Section
                    DeliveryAddressSection(
                      useManualAddress: _useManualAddress,
                      hasAddresses: addressesState.addresses.isNotEmpty,
                      selectedAddress: _selectedSavedAddress,
                      onToggleManualAddress: (manual) {
                        setState(() => _useManualAddress = manual);
                      },
                      onAddressSelected: (address) {
                        setState(() => _selectedSavedAddress = address);
                      },
                      addressController: _addressController,
                      cityController: _cityController,
                      phoneController: _phoneController,
                      labelController: _addressLabelController,
                      saveAddress: _saveNewAddress,
                      onSaveAddressChanged: (save) {
                        setState(() => _saveNewAddress = save);
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),

                    // Payment Mode
                    _buildSectionTitle('Mode de paiement'),
                    const SizedBox(height: 12),
                    PaymentModeSelector(
                      selectedMode: _paymentMode,
                      onModeChanged: (mode) {
                        setState(() => _paymentMode = mode);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Notes
                    _buildSectionTitle('Notes (optionnel)'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Instructions spéciales pour la livraison...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    CheckoutSubmitButton(
                      isSubmitting: _isSubmitting,
                      totalFormatted: currencyFormat.format(cartState.total),
                      onPressed: _submitOrder,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Future<void> _submitOrder() async {
    if (_isSubmitting) {
      _showSnackBar('Commande en cours de traitement...', Colors.orange);
      return;
    }

    if (!_useManualAddress && _selectedSavedAddress == null) {
      _showSnackBar('Veuillez sélectionner une adresse de livraison', Colors.orange);
      return;
    }

    if (_useManualAddress && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final cartState = ref.read(cartProvider);
    final orderItems = _buildOrderItems(cartState);
    final deliveryAddress = _buildDeliveryAddress();

    if (_useManualAddress && _saveNewAddress) {
      await _saveAddressToProfile();
    }

    await ref.read(ordersProvider.notifier).createOrder(
      pharmacyId: cartState.selectedPharmacyId!,
      items: orderItems,
      deliveryAddress: deliveryAddress,
      paymentMode: _paymentMode,
      customerNotes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    final ordersState = ref.read(ordersProvider);

    if (ordersState.status == OrdersStatus.loaded &&
        ordersState.createdOrder != null) {
      await ref.read(cartProvider.notifier).clearCart();

      if (mounted) {
        if (_paymentMode == 'platform') {
          await _processPayment(ordersState.createdOrder!.id);
        } else {
          _showSnackBar('Commande créée avec succès!', AppColors.success);
          _navigateToOrders();
        }
      }
    } else if (ordersState.status == OrdersStatus.error) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showSnackBar(
          _getReadableOrderError(ordersState.errorMessage),
          AppColors.error,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  List<OrderItemEntity> _buildOrderItems(dynamic cartState) {
    return cartState.items.map<OrderItemEntity>((item) {
      return OrderItemEntity(
        productId: item.product.id,
        name: item.product.name,
        quantity: item.quantity,
        unitPrice: item.product.price,
        totalPrice: item.totalPrice,
      );
    }).toList();
  }

  DeliveryAddressEntity _buildDeliveryAddress() {
    if (_useManualAddress) {
      return DeliveryAddressEntity(
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        phone: _phoneController.text.trim(),
      );
    }
    return DeliveryAddressEntity(
      address: _selectedSavedAddress!.fullAddress,
      city: _selectedSavedAddress!.city,
      phone: _selectedSavedAddress!.phone,
      latitude: _selectedSavedAddress!.latitude,
      longitude: _selectedSavedAddress!.longitude,
    );
  }

  String _getReadableOrderError(String? error) {
    if (error == null || error.isEmpty) {
      return 'Une erreur est survenue lors de la création de la commande.';
    }
    
    final errorLower = error.toLowerCase();
    
    if (errorLower.contains('stock') || errorLower.contains('disponible')) {
      return 'Certains produits ne sont plus disponibles. Veuillez vérifier votre panier.';
    }
    if (errorLower.contains('pharmacy') || errorLower.contains('pharmacie')) {
      return 'La pharmacie n\'est pas disponible actuellement. Veuillez en choisir une autre.';
    }
    if (errorLower.contains('network') || errorLower.contains('connexion')) {
      return 'Problème de connexion. Vérifiez votre internet et réessayez.';
    }
    if (errorLower.contains('address') || errorLower.contains('adresse')) {
      return 'L\'adresse de livraison est invalide. Veuillez la vérifier.';
    }
    
    return 'Une erreur est survenue. Veuillez réessayer.';
  }

  Future<void> _processPayment(int orderId) async {
    if (!mounted) return;

    final provider = await PaymentProviderDialog.show(context);

    if (provider == null) {
      if (mounted) _navigateToOrders();
      return;
    }

    if (!mounted) return;

    PaymentLoadingDialog.show(context);

    final result = await ref
        .read(ordersProvider.notifier)
        .initiatePayment(orderId: orderId, provider: provider);

    if (!mounted) return;
    PaymentLoadingDialog.hide(context);

    if (result != null && result.containsKey('payment_url')) {
      final url = Uri.parse(result['payment_url']);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          _showSnackBar('Impossible d\'ouvrir le lien de paiement', AppColors.error);
        }
      }
    } else {
      if (mounted) {
        _showSnackBar(
          'Erreur lors de l\'initialisation du paiement',
          AppColors.error,
        );
      }
    }

    if (mounted) _navigateToOrders();
  }

  Future<void> _saveAddressToProfile() async {
    try {
      final label = _addressLabelController.text.trim().isNotEmpty
          ? _addressLabelController.text.trim()
          : 'Adresse ${DateTime.now().day}/${DateTime.now().month}';
      
      await ref.read(addressesProvider.notifier).createAddress(
        label: label,
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        phone: _phoneController.text.trim(),
        isDefault: ref.read(addressesProvider).addresses.isEmpty,
      );
      
      if (mounted) {
        ErrorHandler.showSuccessSnackBar(context, 'Adresse "$label" enregistrée');
      }
    } catch (e) {
      AppLogger.error('Erreur lors de l\'enregistrement de l\'adresse', error: e);
    }
  }

  void _showSnackBar(
    String message,
    Color backgroundColor, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (backgroundColor == AppColors.success) {
      ErrorHandler.showSuccessSnackBar(context, message);
    } else if (backgroundColor == AppColors.error) {
      ErrorHandler.showErrorSnackBar(context, message);
    } else {
      ErrorHandler.showWarningSnackBar(context, message);
    }
  }

  void _navigateToOrders() {
    context.goToOrders();
  }
}
