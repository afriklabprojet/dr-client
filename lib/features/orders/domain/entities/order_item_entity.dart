import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final int? id;
  final String name;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const OrderItemEntity({
    this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [id, name, quantity, unitPrice, totalPrice];
}
