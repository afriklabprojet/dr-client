// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
  role: json['role'] as String?,
  avatar: json['avatar'] as String?,
  emailVerifiedAt: json['email_verified_at'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'role': instance.role,
  'avatar': instance.avatar,
  'email_verified_at': instance.emailVerifiedAt,
  'created_at': instance.createdAt,
};
