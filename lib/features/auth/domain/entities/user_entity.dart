import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? address;
  final String? profilePicture;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    this.profilePicture,
    this.emailVerifiedAt,
    required this.createdAt,
  });

  bool get isEmailVerified => emailVerifiedAt != null;

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        address,
        profilePicture,
        emailVerifiedAt,
        createdAt,
      ];
}
