// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  price: _parsePrice(json['price']),
  imageUrl: json['image_url'] as String?,
  image: json['image'] as String?,
  stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
  manufacturer: json['manufacturer'] as String?,
  requiresPrescription: json['requires_prescription'] as bool? ?? false,
  pharmacy: PharmacyModel.fromJson(json['pharmacy'] as Map<String, dynamic>),
  category: _categoryFromJson(json['category']),
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'image_url': instance.imageUrl,
      'image': instance.image,
      'stock_quantity': instance.stockQuantity,
      'manufacturer': instance.manufacturer,
      'requires_prescription': instance.requiresPrescription,
      'pharmacy': instance.pharmacy,
      'category': instance.category,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
