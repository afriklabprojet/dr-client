import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/delivery_address_entity.dart';
import 'order_item_model.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel {
  final int id;
  final String reference;
  @JsonKey(name: 'status')
  final String status;
  @JsonKey(name: 'delivery_code')
  final String? deliveryCode;
  @JsonKey(name: 'payment_mode')
  final String paymentMode;
  @JsonKey(name: 'pharmacy_id')
  final int? pharmacyId;
  @JsonKey(name: 'pharmacy')
  final PharmacyBasicModel? pharmacy;
  final List<OrderItemModel> items;
  final double subtotal;
  @JsonKey(name: 'delivery_fee')
  final double deliveryFee;
  @JsonKey(name: 'total_amount')
  final double totalAmount;
  final String currency;
  @JsonKey(name: 'delivery_address')
  final String deliveryAddress;
  @JsonKey(name: 'delivery_city')
  final String? deliveryCity;
  @JsonKey(name: 'delivery_latitude')
  final double? deliveryLatitude;
  @JsonKey(name: 'delivery_longitude')
  final double? deliveryLongitude;
  @JsonKey(name: 'customer_phone')
  final String? customerPhone;
  @JsonKey(name: 'customer_notes')
  final String? customerNotes;
  @JsonKey(name: 'prescription_image')
  final String? prescriptionImage;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'confirmed_at')
  final String? confirmedAt;
  @JsonKey(name: 'paid_at')
  final String? paidAt;
  @JsonKey(name: 'delivered_at')
  final String? deliveredAt;
  @JsonKey(name: 'cancelled_at')
  final String? cancelledAt;
  @JsonKey(name: 'cancellation_reason')
  final String? cancellationReason;

  const OrderModel({
    required this.id,
    required this.reference,
    this.deliveryCode,
    required this.status,
    required this.paymentMode,
    this.pharmacyId,
    this.pharmacy,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    this.currency = 'XOF',
    required this.deliveryAddress,
    this.deliveryCity,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.customerPhone,
    this.customerNotes,
    this.prescriptionImage,
    required this.createdAt,
    this.confirmedAt,
    this.paidAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      reference: reference,
      deliveryCode: deliveryCode,
      status: _parseOrderStatus(status),
      paymentMode: _parsePaymentMode(paymentMode),
      pharmacyId: pharmacyId ?? pharmacy?.id ?? 0,
      pharmacyName: pharmacy?.name ?? '',
      pharmacyPhone: pharmacy?.phone,
      pharmacyAddress: pharmacy?.address,
      items: items.map((item) => item.toEntity()).toList(),
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      totalAmount: totalAmount,
      currency: currency,
      deliveryAddress: DeliveryAddressEntity(
        address: deliveryAddress,
        city: deliveryCity,
        latitude: deliveryLatitude,
        longitude: deliveryLongitude,
        phone: customerPhone,
      ),
      customerNotes: customerNotes,
      prescriptionImage: prescriptionImage,
      createdAt: DateTime.parse(createdAt),
      confirmedAt: confirmedAt != null ? DateTime.parse(confirmedAt!) : null,
      paidAt: paidAt != null ? DateTime.parse(paidAt!) : null,
      deliveredAt: deliveredAt != null ? DateTime.parse(deliveredAt!) : null,
      cancelledAt: cancelledAt != null ? DateTime.parse(cancelledAt!) : null,
      cancellationReason: cancellationReason,
    );
  }

  OrderStatus _parseOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'ready':
        return OrderStatus.ready;
      case 'delivering':
        return OrderStatus.delivering;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'failed':
        return OrderStatus.failed;
      default:
        return OrderStatus.pending;
    }
  }

  PaymentMode _parsePaymentMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'platform':
        return PaymentMode.platform;
      case 'on_delivery':
        return PaymentMode.onDelivery;
      default:
        return PaymentMode.platform;
    }
  }
}

@JsonSerializable()
class PharmacyBasicModel {
  final int id;
  final String name;
  final String? phone;
  final String? address;

  const PharmacyBasicModel({
    required this.id,
    required this.name,
    this.phone,
    this.address,
  });

  factory PharmacyBasicModel.fromJson(Map<String, dynamic> json) =>
      _$PharmacyBasicModelFromJson(json);

  Map<String, dynamic> toJson() => _$PharmacyBasicModelToJson(this);
}
