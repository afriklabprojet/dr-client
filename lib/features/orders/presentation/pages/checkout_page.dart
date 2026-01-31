// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../addresses/domain/entities/address_entity.dart';
import '../../../addresses/presentation/providers/addresses_provider.dart';
import '../../../addresses/presentation/widgets/address_selector.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../domain/entities/delivery_address_entity.dart';
import '../providers/orders_state.dart';
import '../providers/orders_provider.dart';
import 'orders_list_page.dart';

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

  String _paymentMode = AppConstants.paymentModePlatform; // platform or on_delivery
  bool _useManualAddress = false; // Toggle pour adresse manuelle
  bool _saveNewAddress = false; // Option pour enregistrer la nouvelle adresse
  bool _isSubmitting = false; // Protection contre double clic
  AddressEntity? _selectedSavedAddress;

  @override
  void initState() {
    super.initState();
    // Charger les adresses et pré-sélectionner la défaut
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

  /// Pré-remplit le numéro de téléphone depuis le profil utilisateur
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
                    _buildOrderSummary(cartState, currencyFormat),
                    const SizedBox(height: 24),

                    // Delivery Address Section
                    _buildDeliveryAddressSection(isDark),
                    const SizedBox(height: 24),


                    // Payment Mode
                    _buildSectionTitle('Mode de paiement'),
                    const SizedBox(height: 12),
                    _buildPaymentMode(),
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

                    // Total and Submit
                    _buildCheckoutButton(cartState, currencyFormat),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOrderSummary(dynamic cartState, NumberFormat currencyFormat) {
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
            ...cartState.items.map(
              (item) => Padding(
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
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sous-total'),
                Text(currencyFormat.format(cartState.subtotal)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Frais de livraison'),
                Text(currencyFormat.format(cartState.deliveryFee)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  currencyFormat.format(cartState.total),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
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

  /// Nouvelle section pour les adresses avec option saved/manuel
  Widget _buildDeliveryAddressSection(bool isDark) {
    final addressesState = ref.watch(addressesProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle entre adresse sauvegardée et manuelle
        if (addressesState.addresses.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: _buildAddressTypeButton(
                  icon: Icons.bookmark,
                  label: 'Adresse enregistrée',
                  isSelected: !_useManualAddress,
                  onTap: () => setState(() => _useManualAddress = false),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAddressTypeButton(
                  icon: Icons.edit_location_alt,
                  label: 'Nouvelle adresse',
                  isSelected: _useManualAddress,
                  onTap: () => setState(() => _useManualAddress = true),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        
        // Afficher le sélecteur ou le formulaire
        if (_useManualAddress || addressesState.addresses.isEmpty)
          _buildDeliveryForm(isDark)
        else
          AddressSelector(
            initialAddress: _selectedSavedAddress,
            onAddressSelected: (address) {
              setState(() {
                _selectedSavedAddress = address;
              });
            },
          ),
      ],
    );
  }

  Widget _buildAddressTypeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withValues(alpha: 0.1) 
              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary 
                : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected 
                      ? AppColors.primary 
                      : (isDark ? Colors.white70 : AppColors.textSecondary),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryForm(bool isDark) {
    return Column(
      children: [
        TextFormField(
          controller: _addressController,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: const InputDecoration(
            labelText: 'Adresse complète *',
            hintText: 'Ex: 123 Rue des Jardins, Cocody',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Veuillez entrer votre adresse';
            }
            if (value.trim().length < 10) {
              return 'Adresse trop courte';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _cityController,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: const InputDecoration(
            labelText: 'Ville *',
            hintText: 'Ex: Abidjan',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_city),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Veuillez entrer la ville';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: const InputDecoration(
            labelText: 'Téléphone *',
            hintText: '+225 07 00 00 00 00',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Veuillez entrer votre numéro';
            }
            if (value.trim().length < 8) {
              return 'Numéro invalide';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Option pour enregistrer l'adresse
        _buildSaveAddressOption(isDark),
      ],
    );
  }

  Widget _buildSaveAddressOption(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _saveNewAddress 
            ? AppColors.primary.withValues(alpha: 0.1) 
            : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _saveNewAddress 
              ? AppColors.primary.withValues(alpha: 0.3)
              : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _saveNewAddress = !_saveNewAddress),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _saveNewAddress,
                    onChanged: (value) => setState(() => _saveNewAddress = value ?? false),
                    activeColor: AppColors.primary,
                    side: BorderSide(
                      color: isDark ? Colors.white60 : Colors.grey,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enregistrer cette adresse',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        'Pour vos prochaines commandes',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _saveNewAddress ? Icons.bookmark : Icons.bookmark_border,
                  color: _saveNewAddress 
                      ? AppColors.primary 
                      : (isDark ? Colors.white60 : AppColors.textHint),
                ),
              ],
            ),
          ),
          // Champ pour le label de l'adresse (si on veut enregistrer)
          if (_saveNewAddress) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressLabelController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Nom de l\'adresse',
                hintText: 'Ex: Maison, Bureau, Chez maman...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.label_outline),
                isDense: true,
              ),
              validator: (value) {
                if (_saveNewAddress && (value == null || value.trim().isEmpty)) {
                  return 'Donnez un nom à cette adresse';
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMode() {
    return Column(
      children: [
        RadioListTile<String>(
          value: AppConstants.paymentModePlatform,
          groupValue: _paymentMode,
          onChanged: (value) => setState(() => _paymentMode = value!),
          title: const Text('Paiement en ligne'),
          subtitle: const Text('Payez maintenant par mobile money'),
          secondary: const Icon(Icons.payment, color: AppColors.primary),
        ),
        RadioListTile<String>(
          value: AppConstants.paymentModeOnDelivery,
          groupValue: _paymentMode,
          onChanged: (value) => setState(() => _paymentMode = value!),
          title: const Text('Paiement à la livraison'),
          subtitle: const Text('Payez en espèces lors de la réception'),
          secondary: const Icon(
            Icons.local_shipping,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton(dynamic cartState, NumberFormat currencyFormat) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : () => _submitOrder(),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: _isSubmitting ? Colors.grey : AppColors.primary,
        ),
        child: _isSubmitting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Traitement en cours...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            : Text(
                'Confirmer la commande - ${currencyFormat.format(cartState.total)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _submitOrder() async {
    // Protection contre double clic
    if (_isSubmitting) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commande en cours de traitement...'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Validation de l'adresse
    if (!_useManualAddress && _selectedSavedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une adresse de livraison'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_useManualAddress && !_formKey.currentState!.validate()) {
      return;
    }

    // Activer la protection contre double clic
    setState(() => _isSubmitting = true);

    final cartState = ref.read(cartProvider);

    // Convert cart items to order items
    final orderItems = cartState.items.map((item) {
      return OrderItemEntity(
        productId: item.product.id,
        name: item.product.name,
        quantity: item.quantity,
        unitPrice: item.product.price,
        totalPrice: item.totalPrice,
      );
    }).toList();

    // Create delivery address based on selection
    final DeliveryAddressEntity deliveryAddress;
    
    if (_useManualAddress) {
      deliveryAddress = DeliveryAddressEntity(
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      
      // Enregistrer l'adresse si l'utilisateur l'a demandé
      if (_saveNewAddress) {
        await _saveAddressToProfile();
      }
    } else {
      // Utiliser l'adresse sauvegardée
      deliveryAddress = DeliveryAddressEntity(
        address: _selectedSavedAddress!.fullAddress,
        city: _selectedSavedAddress!.city,
        phone: _selectedSavedAddress!.phone,
        latitude: _selectedSavedAddress!.latitude,
        longitude: _selectedSavedAddress!.longitude,
      );
    }

    // Create order
    await ref
        .read(ordersProvider.notifier)
        .createOrder(
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
      // Clear cart
      await ref.read(cartProvider.notifier).clearCart();

      // Show success and navigate
      if (mounted) {
        if (_paymentMode == 'platform') {
          await _processPayment(ordersState.createdOrder!.id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Commande créée avec succès!'),
              backgroundColor: AppColors.success,
            ),
          );

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const OrdersListPage()),
            (route) => route.isFirst,
          );
        }
      }
    } else if (ordersState.status == OrdersStatus.error) {
      // Réinitialiser le flag en cas d'erreur
      if (mounted) {
        setState(() => _isSubmitting = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _getReadableOrderError(ordersState.errorMessage),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Convertit les erreurs de commande en messages lisibles
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
    // Show provider selection
    if (!mounted) return;

    final provider = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SimpleDialog(
        title: const Text('Choisir le moyen de paiement'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'cinetpay'),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  Icon(Icons.payment, color: Colors.orange, size: 28),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CinetPay',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Orange Money, MTN, Moov, Visa',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'jeko'),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.blue,
                    size: 28,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jèko',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Paiement agrégé',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (provider == null) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const OrdersListPage()),
          (route) => route.isFirst,
        );
      }
      return;
    }

    if (!mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Initialisation du paiement...'),
              ],
            ),
          ),
        ),
      ),
    );

    // Call initiatePayment
    final result = await ref
        .read(ordersProvider.notifier)
        .initiatePayment(orderId: orderId, provider: provider);

    if (!mounted) return;

    // Hide loading
    Navigator.pop(context);

    if (result != null && result.containsKey('payment_url')) {
      final url = Uri.parse(result['payment_url']);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir le lien de paiement'),
          ),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'initialisation du paiement'),
          backgroundColor: AppColors.error,
        ),
      );
    }

    if (!mounted) return;

    // Always navigate to orders list at the end
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OrdersListPage()),
      (route) => route.isFirst,
    );
  }

  /// Enregistre l'adresse manuelle dans le profil utilisateur
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
        isDefault: ref.read(addressesProvider).addresses.isEmpty, // Défaut si première adresse
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Adresse "$label" enregistrée'),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Silently fail - l'adresse n'est pas critique pour la commande
      debugPrint('Erreur lors de l\'enregistrement de l\'adresse: $e');
    }
  }
}
