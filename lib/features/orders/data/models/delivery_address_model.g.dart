// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_address_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryAddressModel _$DeliveryAddressModelFromJson(
  Map<String, dynamic> json,
) => DeliveryAddressModel(
  address: json['address'] as String,
  city: json['city'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  phone: json['phone'] as String?,
);

Map<String, dynamic> _$DeliveryAddressModelToJson(
  DeliveryAddressModel instance,
) => <String, dynamic>{
  'address': instance.address,
  'city': instance.city,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'phone': instance.phone,
};
