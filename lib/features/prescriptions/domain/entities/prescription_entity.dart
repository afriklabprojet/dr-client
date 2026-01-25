import 'package:equatable/equatable.dart';

class PrescriptionEntity extends Equatable {
  final int id;
  final String status; // pending, validated, rejected
  final String? notes;
  final List<String> imageUrls;
  final String? rejectionReason;
  final double? quoteAmount;
  final String? pharmacyNotes;
  final DateTime createdAt;
  final DateTime? validatedAt;

  const PrescriptionEntity({
    required this.id,
    required this.status,
    this.notes,
    required this.imageUrls,
    this.rejectionReason,
    this.quoteAmount,
    this.pharmacyNotes,
    required this.createdAt,
    this.validatedAt,
  });

  PrescriptionEntity copyWith({
    int? id,
    String? status,
    String? notes,
    List<String>? imageUrls,
    String? rejectionReason,
    double? quoteAmount,
    String? pharmacyNotes,
    DateTime? createdAt,
    DateTime? validatedAt,
  }) {
    return PrescriptionEntity(
      id: id ?? this.id,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      imageUrls: imageUrls ?? this.imageUrls,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      quoteAmount: quoteAmount ?? this.quoteAmount,
      pharmacyNotes: pharmacyNotes ?? this.pharmacyNotes,
      createdAt: createdAt ?? this.createdAt,
      validatedAt: validatedAt ?? this.validatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        status,
        notes,
        imageUrls,
        rejectionReason,
        quoteAmount,
        pharmacyNotes,
        createdAt,
        validatedAt,
      ];
}
