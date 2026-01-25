import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? role;
  final String? avatar;
  @JsonKey(name: 'email_verified_at')
  final String? emailVerifiedAt;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role,
    this.avatar,
    this.emailVerifiedAt,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      address: role, // Using role as address for now
      profilePicture: avatar,
      emailVerifiedAt: emailVerifiedAt != null
          ? DateTime.parse(emailVerifiedAt!)
          : null,
      createdAt: createdAt != null
          ? DateTime.parse(createdAt!)
          : DateTime.now(),
    );
  }
}
