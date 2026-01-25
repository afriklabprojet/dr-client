import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/address_entity.dart';
import '../providers/addresses_provider.dart';

/// Page d'édition d'une adresse existante
class EditAddressPage extends ConsumerStatefulWidget {
  final AddressEntity address;
  
  const EditAddressPage({
    super.key,
    required this.address,
  });

  @override
  ConsumerState<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends ConsumerState<EditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _districtController;
  late final TextEditingController _phoneController;
  late final TextEditingController _instructionsController;
  
  late String _selectedLabel;
  late bool _isDefault;
  double? _latitude;
  double? _longitude;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    // Pré-remplir avec les données existantes
    _addressController = TextEditingController(text: widget.address.address);
    _cityController = TextEditingController(text: widget.address.city ?? '');
    _districtController = TextEditingController(text: widget.address.district ?? '');
    _phoneController = TextEditingController(text: widget.address.phone ?? '');
    _instructionsController = TextEditingController(text: widget.address.instructions ?? '');
    _selectedLabel = widget.address.label;
    _isDefault = widget.address.isDefault;
    _latitude = widget.address.latitude;
    _longitude = widget.address.longitude;
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _phoneController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addressesProvider);
    final labelsAsync = ref.watch(addressLabelsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier l\'adresse'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Label selector
            _buildSectionTitle('Type d\'adresse'),
            const SizedBox(height: 8),
            labelsAsync.when(
              data: (labels) => _buildLabelSelector(labels),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => _buildLabelSelector(
                ['Maison', 'Bureau', 'Famille', 'Autre'],
              ),
            ),
            const SizedBox(height: 24),

            // Address fields
            _buildSectionTitle('Adresse'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Adresse complète *',
                hintText: 'Ex: Rue des Jardins, Lot 45',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'L\'adresse est requise';
                }
                return null;
              },
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _districtController,
                    decoration: const InputDecoration(
                      labelText: 'Quartier',
                      hintText: 'Ex: Cocody',
                      prefixIcon: Icon(Icons.map_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Ville',
                      hintText: 'Ex: Abidjan',
                      prefixIcon: Icon(Icons.location_city_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // GPS Location
            _buildSectionTitle('Position GPS (optionnel)'),
            const SizedBox(height: 8),
            _buildLocationSection(),
            const SizedBox(height: 24),

            // Contact
            _buildSectionTitle('Contact'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Téléphone de contact',
                hintText: 'Ex: +225 07 XX XX XX XX',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            // Instructions
            _buildSectionTitle('Instructions de livraison'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Instructions pour le livreur',
                hintText: 'Ex: Portail bleu, 2ème étage, code: 1234',
                prefixIcon: Icon(Icons.info_outline),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Default address toggle
            SwitchListTile(
              title: const Text('Définir comme adresse par défaut'),
              subtitle: Text(
                'Cette adresse sera utilisée par défaut pour vos commandes',
                style: TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
              value: _isDefault,
              onChanged: (value) => setState(() => _isDefault = value),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: state.isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: state.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Enregistrer les modifications',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildLabelSelector(List<String> labels) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: labels.map((label) {
        final isSelected = _selectedLabel == label;
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getLabelIcon(label),
                size: 18,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() => _selectedLabel = label);
            }
          },
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        );
      }).toList(),
    );
  }

  IconData _getLabelIcon(String label) {
    switch (label.toLowerCase()) {
      case 'maison':
        return Icons.home;
      case 'bureau':
        return Icons.business;
      case 'famille':
        return Icons.family_restroom;
      default:
        return Icons.location_on;
    }
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_latitude != null && _longitude != null) ...[
              Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Position GPS enregistrée',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _latitude = null;
                        _longitude = null;
                      });
                    },
                    child: const Text('Supprimer'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Lat: ${_latitude!.toStringAsFixed(6)}, Lng: ${_longitude!.toStringAsFixed(6)}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                  icon: _isLoadingLocation
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: const Text('Mettre à jour la position'),
                ),
              ),
            ] else ...[
              Text(
                'Ajoutez votre position GPS pour aider le livreur à vous trouver plus facilement.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                  icon: _isLoadingLocation
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  label: Text(
                    _isLoadingLocation
                        ? 'Localisation en cours...'
                        : 'Utiliser ma position actuelle',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permission de localisation refusée'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La localisation est désactivée. Activez-la dans les paramètres.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Position GPS mise à jour'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de localisation: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(addressesProvider.notifier).updateAddress(
      id: widget.address.id,
      label: _selectedLabel,
      address: _addressController.text.trim(),
      city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      district: _districtController.text.trim().isEmpty ? null : _districtController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      instructions: _instructionsController.text.trim().isEmpty ? null : _instructionsController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      isDefault: _isDefault,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Adresse mise à jour avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else {
        final error = ref.read(addressesProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Erreur lors de la mise à jour'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
