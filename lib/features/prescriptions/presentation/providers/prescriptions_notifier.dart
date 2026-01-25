import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/exceptions.dart';
import '../../data/datasources/prescriptions_remote_datasource.dart';
import '../../domain/entities/prescription_entity.dart';
import 'prescriptions_state.dart';

class PrescriptionsNotifier extends StateNotifier<PrescriptionsState> {
  final PrescriptionsRemoteDataSource remoteDataSource;

  PrescriptionsNotifier(this.remoteDataSource)
      : super(const PrescriptionsState.initial());

  // Upload prescription
  Future<void> uploadPrescription({
    required List<XFile> images,
    String? notes,
  }) async {
    state = state.copyWith(status: PrescriptionsStatus.uploading);

    try {
      final response = await remoteDataSource.uploadPrescription(
        images: images,
        notes: notes,
      );

      // Parse response to entity
      final prescription = PrescriptionEntity(
        id: response['id'] as int,
        status: response['status'] as String,
        notes: response['notes'] as String?,
        imageUrls: List<String>.from(response['images'] ?? []), // Backend key is 'images' not 'image_urls'
        rejectionReason: response['rejection_reason'] as String?,
        quoteAmount: response['quote_amount'] != null ? double.tryParse(response['quote_amount'].toString()) : null,
        pharmacyNotes: response['pharmacy_notes'] as String?,
        createdAt: DateTime.parse(response['created_at'] as String),
        validatedAt: response['validated_at'] != null
            ? DateTime.parse(response['validated_at'] as String)
            : null,
      );

      state = state.copyWith(
        status: PrescriptionsStatus.uploaded,
        uploadedPrescription: prescription,
        errorMessage: null,
      );
    } on UnauthorizedException catch (_) {
      state = state.copyWith(
        status: PrescriptionsStatus.unauthorized,
        errorMessage: 'Veuillez vous reconnecter pour envoyer une ordonnance',
      );
      rethrow;
    } catch (e) {
      String errorMessage = 'Erreur lors de l\'envoi';
      if (e.toString().contains('403') || e.toString().contains('PHONE_NOT_VERIFIED')) {
        errorMessage = 'Veuillez vérifier votre numéro de téléphone pour envoyer une ordonnance';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Session expirée. Veuillez vous reconnecter.';
      } else {
        errorMessage = 'Erreur lors de l\'envoi: ${e.toString()}';
      }
      state = state.copyWith(
        status: PrescriptionsStatus.error,
        errorMessage: errorMessage,
      );
      rethrow;
    }
  }

  // Load prescriptions list
  Future<void> loadPrescriptions() async {
    state = state.copyWith(status: PrescriptionsStatus.loading);

    try {
      final data = await remoteDataSource.getPrescriptions();
      
      final prescriptions = data.map((item) {
        return PrescriptionEntity(
          id: item['id'] as int,
          status: item['status'] as String,
          notes: item['notes'] as String?,
          imageUrls: List<String>.from(item['images'] ?? []), // 'images' from backend
          rejectionReason: item['rejection_reason'] as String?,
          quoteAmount: item['quote_amount'] != null ? double.tryParse(item['quote_amount'].toString()) : null,
          pharmacyNotes: item['pharmacy_notes'] as String?,
          createdAt: DateTime.parse(item['created_at'] as String),
          validatedAt: item['validated_at'] != null
              ? DateTime.parse(item['validated_at'] as String)
              : null,
        );
      }).toList();

      state = state.copyWith(
        status: PrescriptionsStatus.loaded,
        prescriptions: prescriptions,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: PrescriptionsStatus.error,
        errorMessage: 'Erreur lors du chargement: ${e.toString()}',
      );
    }
  }

  // Get prescription details
  Future<PrescriptionEntity?> getPrescriptionDetails(int prescriptionId) async {
    try {
      final data = await remoteDataSource.getPrescriptionDetails(prescriptionId);
      
      return PrescriptionEntity(
        id: data['id'] as int,
        status: data['status'] as String,
        notes: data['notes'] as String?,
        imageUrls: List<String>.from(data['images'] ?? []), // 'images'
        rejectionReason: data['rejection_reason'] as String?,
        quoteAmount: data['quote_amount'] != null ? double.tryParse(data['quote_amount'].toString()) : null,
        pharmacyNotes: data['pharmacy_notes'] as String?,
        createdAt: DateTime.parse(data['created_at'] as String),
        validatedAt: data['validated_at'] != null
            ? DateTime.parse(data['validated_at'] as String)
            : null,
      );
    } catch (e) {
      state = state.copyWith(
        status: PrescriptionsStatus.error,
        errorMessage: 'Erreur lors du chargement: ${e.toString()}',
      );
      return null;
    }
  }

  // Pay Prescription
  Future<void> payPrescription(int prescriptionId, {String method = 'mobile_money'}) async {
    state = state.copyWith(status: PrescriptionsStatus.loading); // Or a specific payment status
    try {
      await remoteDataSource.payPrescription(prescriptionId, method);
      
      // Update local state to Paid
      final updatedList = state.prescriptions.map((p) {
        if (p.id == prescriptionId) {
          return p.copyWith(status: 'paid');
        }
        return p;
      }).toList();

      state = state.copyWith(
        status: PrescriptionsStatus.loaded,
        prescriptions: updatedList,
      );
      
      // Refresh details if needed or just update local
    } catch (e) {
      state = state.copyWith(
        status: PrescriptionsStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Clear error
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}
